//
//  HomePrescriptionVM.swift
//  ePills
//
//  Created by Javier Calatrava on 27/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit

protocol HomePrescriptionVMProtocol {
    func addPrescription()
    func remove()
    func takeDose()
    func title() -> String
    func getIconName(timeManager: TimeManagerProtocol?) -> String
    func getMessage(timeManager: TimeManagerProtocol?) -> String
    func getPrescriptionTime(timeManager: TimeManagerProtocol?) -> String
    func getRemainingTimeMessage(timeManager: TimeManagerProtocol?) -> (String, String)
    func updatable() -> Bool
    func getMessageColor(timeManager: TimeManagerProtocol?) -> String
    func getCurrentDoseProgress(timeManager: TimeManagerProtocol) -> Double
    func hasDoses() -> Bool
}

public final class HomePrescriptionVM: ObservableObject {

    // MARK: - Public attributes
    private var view: HomePrescriptionView?

    // MARK: - Private attributes
    private var interactor: MedicineInteractorProtocol
    private var homeCoordinator: HomeCoordinatorProtocol
    internal var timeManager: TimeManagerProtocol

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var medicines: [Medicine] = []

    @Published var currentPage = 0
    @Published var currentPrescription: Medicine = Medicine(name: "", unitsBox: 0, intervalSecs: 0, unitsDose: 0)
    @Published var prescriptionIcon: String = ""
    @Published var prescriptionMessage: String = ""
    @Published var remainingMessageMajor: String = ""
    @Published var remainingMessageMinor: String = ""
    @Published var prescriptionColor: String = ""
    @Published var isUpdatable: Bool = false
    @Published var prescriptionTime: String = ""
    @Published var progressPercentage: Double = 0
    @Published var medicineHasDoses: Bool = false
    @Published var medicine: Medicine?
    @Published var medicinePicture: UIImage?

    var timer: Timer?
    var runCount = 0

    init(interactor: MedicineInteractorProtocol = MedicineInteractor(),
         homeCoordinator: HomeCoordinatorProtocol,
         timeManager: TimeManagerProtocol = TimeManager()) {
        self.interactor = interactor
        self.homeCoordinator = homeCoordinator
        self.timeManager = timeManager

        self.interactor.getMedicinesPublisher()
            .sink { prescriptions in
                self.medicines = prescriptions
                self.refreshVM()
            }
            .store(in: &cancellables)
        self.interactor.getCurrentPrescriptionIndex()
            .sink { currentPrescriptionIndex in
                self.currentPage = currentPrescriptionIndex
                self.refreshVM()
            }
            .store(in: &cancellables)
        self.$medicines
            .sink { medicines in
                AnalyticsManager.shared.setUser(property: UserProperties.medicines, value: String(medicines.count))
                guard medicines.isEmpty else { return }
                self.homeCoordinator.replaceByFirstPrescription(interactor: self.interactor)
                self.refreshVM()
            }
            .store(in: &cancellables)
        self.interactor.flushMedicines()
        timer = Timer.scheduledTimer(timeInterval: 1.0,
                                     target: self,
                                     selector: #selector(fireTimer),
                                     userInfo: nil,
                                     repeats: true)
    }

    @objc func fireTimer() {
        self.refreshVM()
    }

    func refreshVM() {
        self.prescriptionIcon = self.getIconName(timeManager: timeManager)
        self.prescriptionMessage = self.getMessage(timeManager: timeManager)
        self.prescriptionTime = self.getPrescriptionTime(timeManager: timeManager)
        self.progressPercentage = self.getCurrentDoseProgress(timeManager: timeManager)
        self.isUpdatable = self.updatable()
        (self.remainingMessageMajor, self.remainingMessageMinor) =
            self.getRemainingTimeMessage(timeManager: timeManager)
        self.prescriptionColor = self.getMessageColor(timeManager: timeManager)
        self.medicineHasDoses = self.hasDoses()
// This code crashes.
//        self.interactor.getMedicinePicture(medicine:  medicines[currentPage])
//            .sink(receiveCompletion: { _ in
//        }, receiveValue: { image in
//            self.medicinePicture = image
//        }).store(in: &cancellables)
    }
}
extension HomePrescriptionVM: HomePrescriptionVMProtocol {
    func addPrescription() {
        self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor,
                                                     medicine: nil)
    }

    func remove() {

        let medicine = self.medicines[currentPage]
        self.interactor.remove(medicine: medicine)
        self.currentPage = 0
        self.refreshVM()
    }

    func update() {
        guard medicines.count > currentPage else { return }
        let medicine = self.medicines[currentPage]
        self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor,
                                                     medicine: medicine)
        self.refreshVM()
    }

    func calendar() {
        guard medicines.count > currentPage else { return }
        let medicine = self.medicines[currentPage]
        self.homeCoordinator.presentCalendar(interactor: self.interactor,
                                             medicine: medicine)
        self.refreshVM()
    }

    func doseList() {
        guard medicines.count > currentPage else { return }
        let medicine = self.medicines[currentPage]
        self.homeCoordinator.presentDoseList(interactor: self.interactor,
                                             medicine: medicine)
        self.refreshVM()
    }

    func takeDose() {
        guard medicines.count > currentPage else { return }
        let medicine = self.medicines[currentPage]
        self.interactor.takeDose(medicine: medicine, timeManager: TimeManager())
        self.refreshVM()
    }

    func title() -> String {
        guard medicines.count > currentPage else { return "" }
        let prescription = self.medicines[currentPage]
        return "\(prescription.name) [\(prescription.currentCycle.unitsConsumed)/\(prescription.unitsBox)]"
    }

    func getIconName(timeManager: TimeManagerProtocol?) -> String {
        guard medicines.count > currentPage else { return "" }
        let prescription = self.medicines[currentPage]
        switch prescription.getState(timeManager: timeManager ?? TimeManager()) {
        case .notStarted: return "cursor.rays"
        case .ongoing: return "moon.zzz"
        case .ongoingReady: return "alarm"
        case .ongoingEllapsed: return "exclamationmark.triangle"
        case .finished: return "clear"
        }
    }

    func getMessage(timeManager: TimeManagerProtocol?) -> String {
        guard medicines.count > currentPage else { return ("") }
        let prescription = self.medicines[currentPage]

        let prescriptionState = prescription.getState(timeManager: timeManager ?? TimeManager())
        switch prescriptionState {
        case .notStarted: return R.string.localizable.home_prescription_not_started.key.localized
        case .ongoing: return R.string.localizable.home_prescription_onging.key.localized
        case .ongoingReady: return R.string.localizable.home_prescription_ongoing_ready.key.localized
        case .ongoingEllapsed: return R.string.localizable.home_prescription_ongoing_ellapsed.key.localized
        case .finished: return R.string.localizable.home_prescription_finished.key.localized
        }
    }

    func getRemainingTimeMessage(timeManager: TimeManagerProtocol?) -> (String, String) {
        guard medicines.count > currentPage else { return ("", "") }
        let medicine = self.medicines[currentPage]

        guard let nextDose = medicine.getNextDose() else { return ("", "") }
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let tmpTimeManager = timeManager ?? TimeManager()
        let now: Date = Date(timeIntervalSince1970: TimeInterval(tmpTimeManager.timeIntervalSince1970()))
        let nextDoseTimestamp = Date(timeIntervalSince1970: TimeInterval(nextDose))
        let timeDifference = Calendar.current.dateComponents(requestedComponent, from: nextDoseTimestamp, to: now)

        return interactor.timeDifference2Str(timeDifference: timeDifference)
    }

    func getPrescriptionTime(timeManager: TimeManagerProtocol?) -> String {
        guard medicines.count > currentPage else { return ("") }
        let prescription = self.medicines[currentPage]

        let prescriptionState = prescription.getState(timeManager: timeManager ?? TimeManager())
        switch prescriptionState {
        case .notStarted, .finished:
            return ""
        case .ongoing, .ongoingReady, .ongoingEllapsed:
            return self.interactor.getExpirationHourMinute(medicine: prescription)
        }
    }

    func getCurrentDoseProgress(timeManager: TimeManagerProtocol) -> Double {
        guard medicines.count > currentPage else { return 0 }
        let medicine = self.medicines[currentPage]
        guard let nextDose = medicine.currentCycle.nextDose,
            medicine.intervalSecs != 0 else { return 0 }
        guard nextDose - timeManager.timeIntervalSince1970() >= 0 else { return 1 }
        let progress: Double = Double(nextDose - timeManager.timeIntervalSince1970()) / Double(medicine.intervalSecs)
        return 1 - progress
    }

    func hasDoses() -> Bool {
        guard medicines.count > currentPage else { return false }
        let medicine = self.medicines[currentPage]
        return !medicine.currentCycle.doses.isEmpty
    }

    func updatable() -> Bool {
        guard medicines.count > currentPage else { return false }
        let prescription = self.medicines[currentPage]
        let prescriptionState = prescription.getState()
        return prescriptionState == CyclesState.notStarted ||
            prescriptionState == CyclesState.finished

    }

    func getMessageColor(timeManager: TimeManagerProtocol?) -> String {
        guard medicines.count > currentPage else { return ("") }
        let prescription = self.medicines[currentPage]

        switch prescription.getState(timeManager: timeManager ?? TimeManager()) {
        case .notStarted: return R.color.colorWhite.name
        case .ongoing: return R.color.colorWhite.name
        case .ongoingReady: return R.color.colorOrange.name
        case .ongoingEllapsed: return R.color.colorRed.name
        case .finished: return R.color.colorWhite.name
        }
    }
}
