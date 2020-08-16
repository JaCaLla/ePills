//
//  PrescriptionInteractor.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit

protocol MedicineInteractorProtocol {

    func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine?
    func remove(medicine: Medicine)
    func update(medicine: Medicine)
    func takeDose(medicine: Medicine, timeManager: TimeManagerProtocol)
    func getCurrentPrescriptionIndex() -> AnyPublisher<Int, Never>
    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never>
    func flushMedicines()
    func getMedicinePicture(medicine: Medicine) -> Future<UIImage, DataManagerError>
    func setMedicinePicture(medicine: Medicine, picture: UIImage) -> Future<Bool, DataManagerError>
    func timeDifference2Str(timeDifference: DateComponents) -> (String, String)
    func getIntervals() -> [Interval]
    func getCycleDatesStr(medicine: Medicine) -> [String]
    func getCycleDates(medicine: Medicine) -> [Date]
    func getExpirationDayNumber(medicine: Medicine) -> String
    func getExpirationMonthYear(medicine: Medicine) -> String
    func getExpirationWeekdayHourMinute(medicine: Medicine) -> String
    func getExpirationRealDayNumber(dose: Dose) -> String
    func getExpirationRealMonthYear(dose: Dose) -> String
    func getExpirationRealWeekdayHourMinute(dose: Dose) -> String
    func getExpirationHourMinute(medicine: Medicine) -> String
}

final class MedicineInteractor {

    // MARK: - Read only attributes
    private(set) var dataManager: DataManagerProtocol

    // MARK: - Private attributes
    private var medicines: [Medicine] = []
    private let subject = PassthroughSubject <[Medicine], Never >()
    private let currentPrescriptionIndexSubject = PassthroughSubject <Int, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var currentPrescriptionIndex: Int = 0

    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager

        self.dataManager.getMedicinesPublisher()
            .sink { medicines in
                self.medicines = medicines
                self.subject.send(self.medicines)
            }
            .store(in: &cancellables)
    }
}

// MARK: - PrescriptionInteractorProtocol
extension MedicineInteractor: MedicineInteractorProtocol {

    func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine? {
        guard let createdMedicine = dataManager.add(medicine: medicine, timeManager: timeManager) else { return nil }
        if let index = medicines.firstIndex(of: createdMedicine) {
            currentPrescriptionIndex = index
            currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        }
        AnalyticsManager.shared.logEvent(name: Event.selectInterval,
                                         metadata: [ParamEvent.duarionHours: createdMedicine.intervalSecs / 3600])

        AnalyticsManager.shared.logEvent(name: Event.addedMedicine, metadata: [:])
        return createdMedicine
    }
    func remove(medicine: Medicine) {
        LocalNotificationManager.shared.removeNotification(medicine: medicine)
        dataManager.remove(medicine: medicine)
        currentPrescriptionIndex = 0
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        AnalyticsManager.shared.logEvent(name: Event.removedMedicine, metadata: [:])
    }

    func update(medicine: Medicine) {
        dataManager.update(medicine: medicine)
        if let index = medicines.firstIndex(of: medicine) {
            currentPrescriptionIndex = index
            currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        }
        AnalyticsManager.shared.logEvent(name: Event.updatedMedicine, metadata: [:])
    }

    func takeDose(medicine: Medicine, timeManager: TimeManagerProtocol) {

        if !medicine.isLast() {
            LocalNotificationManager.shared.addNotification(medicine: medicine, onComplete: { _ in /* Do nothing */ })
            AnalyticsManager.shared.logEvent(name: Event.takeDose, metadata: [:])
        } else {
            AnalyticsManager.shared.logEvent(name: Event.takeLastDose, metadata: [:])
        }

        var dose = Dose(expected: timeManager.timeIntervalSince1970(), timeManager: timeManager)
        if let nextDose = medicine.currentCycle.nextDose {
            dose = Dose(expected: nextDose, timeManager: timeManager)
        }
        _ = dataManager.add(dose: dose, medicine: medicine)
        medicine.takeDose(timeManager: timeManager)
        self.update(medicine: medicine)
    }

    func getCurrentPrescriptionIndex() -> AnyPublisher<Int, Never> {
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        return currentPrescriptionIndexSubject.eraseToAnyPublisher()
    }

    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never> {
        self.dataManager.getMedicinesPublisher()
            .sink { medicines in
                self.medicines = medicines
                //   self.subject.send(self.medicines)
            }
            .store(in: &cancellables)
        return subject.eraseToAnyPublisher()
    }

    func flushMedicines() {
        self.dataManager.flushMedicines()
    }

    func getMedicinePicture(medicine: Medicine) -> Future<UIImage, DataManagerError> {
        return Future<UIImage, DataManagerError> { [weak self] promise in
            if let weakSelf = self,
                medicine.pictureFilename != nil {
                _ = weakSelf.dataManager
                    .getMedicinePicture(medicine: medicine)
                    .sink(receiveCompletion: { (result) in
                        if result != .finished {
                            promise(.failure(.pictureNotFound))
                        }
                    }) { image in
                        promise(.success(image))
                }.store(in: &weakSelf.cancellables)
            } else {
                promise(.failure(.pictureNotFound))
            }
        }
    }

    func setMedicinePicture(medicine: Medicine, picture: UIImage) -> Future<Bool, DataManagerError> {
        //medicine.pictureFilename = "\(Date().timeIntervalSince1970)"
        return Future<Bool, DataManagerError> { [weak self] promise in
            guard let weakSelf = self,
                medicine.pictureFilename != nil else {
                    promise(.failure(.pictureNotStored))
                    return
            }
            _ = weakSelf.dataManager
                .setMedicinePicture(medicine: medicine, picture: picture)
                .sink(receiveCompletion: { (result) in
                    if result != .finished {
                        promise(.failure(.pictureNotStored))
                    }
                }) { result in
                    promise(.success(result))
            }
            .store(in: &weakSelf.cancellables)
        }
    }

    func timeDifference2Str(timeDifference: DateComponents) -> (String, String) {
        if let years = timeDifference.year,
            years != 0 {
            return (R.string.localizable.home_prescription_more_than_month.key.localized, "")
        } else if let months = timeDifference.month,
            months != 0 {
            return (R.string.localizable.home_prescription_more_than_month.key.localized, "")
        } else if let days = timeDifference.day,
            days != 0,
            let hours = timeDifference.hour {
            return (String(format: "%02d%@", days, R.string.localizable.home_prescription_days_suffix.key.localized),
                    String(format: "%02d%@",
                           abs(hours), R.string.localizable.home_prescription_hours_suffix.key.localized))
        } else if let hours = timeDifference.hour,
            hours != 0,
            let mins = timeDifference.minute {
            return (String(format: "%02d%@", hours, R.string.localizable.home_prescription_hours_suffix.key.localized),
                    String(format: "%02d%@",
                           abs(mins), R.string.localizable.home_prescription_mins_suffix.key.localized))
        } else if let mins = timeDifference.minute,
            mins != 0,
            let secs = timeDifference.second {
            return (String(format: "%02d%@", mins, R.string.localizable.home_prescription_mins_suffix.key.localized),
                    String(format: "%02d%@",
                           abs(secs), R.string.localizable.home_prescription_secs_suffix.key.localized))
        } else if let secs = timeDifference.second {
            return (String(format: "%02d%@",
                           secs, R.string.localizable.home_prescription_secs_suffix.key.localized), "")
        } else {
            return ("", "")
        }
    }

    func getIntervals() -> [Interval] {

        let secsPerHour = 3600

        var invervals: [Interval] = []
        #if DEBUG
            invervals.append(Interval(secs: 60, label: "_60 Secs"))
        #endif
        invervals.append(Interval(secs: 1 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_1_hour.key.localized))
        invervals.append(Interval(secs: 2 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_2_hours.key.localized))
        invervals.append(Interval(secs: 4 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_4_hours.key.localized))
        invervals.append(Interval(secs: 6 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_6_hours.key.localized))
        invervals.append(Interval(secs: 8 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_8_hours.key.localized))
        invervals.append(Interval(secs: 12 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_12_hours.key.localized))
        invervals.append(Interval(secs: 24 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_1_day.key.localized))
        invervals.append(Interval(secs: 48 * secsPerHour,
                                  label: R.string.localizable.prescription_form_interval_list_2_days.key.localized))

        return invervals
    }

    func getCycleDatesStr(medicine: Medicine) -> [String] {
        var from = medicine.currentCycle.update
        if let firstDose = medicine.currentCycle.doses.first {
            from = firstDose.real
        }
        let toDate = from + medicine.intervalSecs * ((medicine.unitsBox / medicine.unitsDose) - 1)
        return datesRange(fromSecs: from, toSecs: toDate).map({ $0.dateFormatUTC() })
    }

    func getCycleDates(medicine: Medicine) -> [Date] {

        let cycles = self.getCycleDatesStr(medicine: medicine)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return cycles.map({ dateFormatter.date(from: $0) ?? Date() })
    }

    func getExpirationDayNumber(medicine: Medicine) -> String {
        var from = medicine.currentCycle.update
        if let firstDose = medicine.currentCycle.doses.first {
            from = firstDose.real
        }
        let toSecs = from + medicine.intervalSecs * ((medicine.unitsBox / medicine.unitsDose) - 1)
        let toDate = Date(timeIntervalSince1970: TimeInterval(toSecs))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: toDate).replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }

    func getExpirationMonthYear(medicine: Medicine) -> String {
        var from = medicine.currentCycle.update
        if let firstDose = medicine.currentCycle.doses.first {
            from = firstDose.real
        }
        let toSecs = from + medicine.intervalSecs * ((medicine.unitsBox / medicine.unitsDose) - 1)
        let toDate = Date(timeIntervalSince1970: TimeInterval(toSecs))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: toDate)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: toDate)
        return "\(monthName.capitalized) - \(year)"
    }

    func getExpirationWeekdayHourMinute(medicine: Medicine) -> String {
        var from = medicine.currentCycle.update
        if let firstDose = medicine.currentCycle.doses.first {
            from = firstDose.real
        }
        let toSecs = from + medicine.intervalSecs * ((medicine.unitsBox / medicine.unitsDose) - 1)
        let toDate = Date(timeIntervalSince1970: TimeInterval(toSecs))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: toDate)
        formatter.dateFormat = "HH:mm"
        let hhmm = formatter.string(from: toDate)
        return "\(weekday.capitalized) - \(hhmm)"
    }

    func getExpirationRealDayNumber(dose: Dose) -> String {
        let toDate = Date(timeIntervalSince1970: TimeInterval(dose.real))
        let formatter = DateFormatter()
        formatter.dateFormat = "dd"
        return formatter.string(from: toDate).replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
    }

    func getExpirationRealMonthYear(dose: Dose) -> String {

        let toDate = Date(timeIntervalSince1970: TimeInterval(dose.real))
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        let monthName = formatter.string(from: toDate)
        formatter.dateFormat = "yyyy"
        let year = formatter.string(from: toDate)
        return "\(monthName.capitalized) - \(year)"
    }

    func getExpirationRealWeekdayHourMinute(dose: Dose) -> String {
        let toDate = Date(timeIntervalSince1970: TimeInterval(dose.real))
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        let weekday = formatter.string(from: toDate)
        formatter.dateFormat = "HH:mm"
        let hhmm = formatter.string(from: toDate)
        return "\(weekday.capitalized) - \(hhmm)"
    }

    func getExpirationHourMinute(medicine: Medicine) -> String {
        guard let nextDose = medicine.currentCycle.nextDose else { return "" }
        let toDate = Date(timeIntervalSince1970: TimeInterval(nextDose))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: toDate)
    }

    // MARK: - Private functions
    private func datesRange(fromSecs: Int, toSecs: Int) -> [Date] {
        let fromDate = Date(timeIntervalSince1970: TimeInterval(fromSecs))
        let toDate = Date(timeIntervalSince1970: TimeInterval(toSecs))
        if fromDate > toDate { return [Date]() }

        var tempDate = fromDate
        var array = [tempDate]

        while tempDate < toDate {
            tempDate = Calendar.current.date(byAdding: .day, value: 1, to: tempDate) ?? Date()
            array.append(tempDate)
        }
        return array
    }
}

extension Date {
    func dateFormatUTC() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let newdate = Date.init(timeInterval: 0, since: self)
        let dateInFormat = dateFormatter.string(from: newdate)
        return dateInFormat
    }
}
