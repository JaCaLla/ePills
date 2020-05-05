//
//  HomePrescriptionVM.swift
//  ePills
//
//  Created by Javier Calatrava on 27/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol HomePrescriptionVMProtocol {
    func addPrescription()
    func remove(prescription: Prescription)
    func title() -> String
    func getIconName(prescription: Prescription, timeManager: TimeManagerPrococol) -> String
    func getMessage(prescription: Prescription, timeManager: TimeManagerPrococol) -> String
}

public final class HomePrescriptionVM: ObservableObject {

    // MARK: - Public attributes
    private var view: HomePrescriptionView?

    // MARK: - Private attributes
    private var interactor: PrescriptionInteractorProtocol
    private var homeCoordinator: HomeCoordinatorProtocol

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var prescriptions: [Prescription] = []
    @Published var dosePrescription: Prescription? {
        didSet {
            print("todo")
        }
    }
    @Published var currentPage = 0

    init(interactor: PrescriptionInteractorProtocol = PrescriptionInteractor(),
         homeCoordinator: HomeCoordinatorProtocol) {
        self.interactor = interactor
        self.homeCoordinator = homeCoordinator
        /*interactor.$prescriptions
            .assign(to: \.prescriptions, on: self)
            .store(in: &cancellables)
        */
        self.interactor.getPrescriptions()
            .sink { prescriptions in
                self.prescriptions = prescriptions
            }.store(in: &cancellables)
        self.interactor.getCurrentPrescriptionIndex()
            .sink { currentPrescriptionIndex in
                self.currentPage = currentPrescriptionIndex
            }.store(in: &cancellables)
        self.$prescriptions
            .sink { someValue in
                guard someValue.isEmpty else { return }
                self.homeCoordinator.replaceByFirstPrescription(interactor: self.interactor)
            }.store(in: &cancellables)
    }
}


extension HomePrescriptionVM: HomePrescriptionVMProtocol {
    func addPrescription() {
        self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor)
    }

    func remove(prescription: Prescription) {
        self.interactor.remove(prescription: prescription)
        self.currentPage = 0
    }

    func title() -> String {
        guard prescriptions.count > currentPage else { return "" }
        let prescription = self.prescriptions[currentPage]
        return "\(prescription.name) [\(prescription.unitsConsumed)/\(prescription.unitsBox)]"
    }

    func getIconName(prescription: Prescription, timeManager: TimeManagerPrococol) -> String {
        switch prescription.getState(timeManager: timeManager) {
        case .notStarted: return "stop"
        case .ongoing: return "play"
        case .ongoingReady: return "alarm"
        case .ongoingEllapsed: return "exclamationmark.triangle"
        case .finished: return "clear"
        }
    }

    func getMessage(prescription: Prescription, timeManager: TimeManagerPrococol) -> String {
        switch prescription.getState(timeManager: timeManager) {
        case .notStarted: return R.string.localizable.home_prescription_not_started.key.localized
        case .ongoing: return R.string.localizable.home_prescription_onging.key.localized
        case .ongoingReady: return R.string.localizable.home_prescription_ongoing_ready.key.localized
        case .ongoingEllapsed: return R.string.localizable.home_prescription_ongoing_ellapsed.key.localized
        case .finished: return R.string.localizable.home_prescription_finished.key.localized
        }
    }

    func getMajorRemainingTimeMessage(prescription: Prescription, timeManager: TimeManagerPrococol) -> (String, String) {
        guard let nextDose = prescription.nextDose else { return ("", "") }
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]

        let now: Date = Date(timeIntervalSince1970: TimeInterval(timeManager.timeIntervalSince1970()))
        let nextDoseTimestamp = Date(timeIntervalSince1970: TimeInterval(nextDose))
        let timeDifference = Calendar.current.dateComponents(requestedComponent, from: nextDoseTimestamp, to:now )

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
                    String(format: "%02d%@", abs(hours), R.string.localizable.home_prescription_hours_suffix.key.localized))
        } else if let hours = timeDifference.hour,
            hours != 0,
            let mins = timeDifference.minute {
            return (String(format: "%02d%@", hours, R.string.localizable.home_prescription_hours_suffix.key.localized),
                    String(format: "%02d%@", abs(mins), R.string.localizable.home_prescription_mins_suffix.key.localized))
        } else if let mins = timeDifference.minute,
            mins != 0,
            let secs = timeDifference.second {
            return (String(format: "%02d%@", mins, R.string.localizable.home_prescription_mins_suffix.key.localized),
                    String(format: "%02d%@", abs(secs), R.string.localizable.home_prescription_secs_suffix.key.localized))
        } else if let secs = timeDifference.second {
            return (String(format: "%02d%@", secs, R.string.localizable.home_prescription_secs_suffix.key.localized),
                    "")
        } else {
             return ("", "")
        }
    }

    func getMinorRemainingTimeMessage(prescription: Prescription, timeManager: TimeManagerPrococol) -> String {
        if let remainingDays = prescription.getRemainingDays(timeManager: timeManager),
            remainingDays > 0,
            let remainingHours = prescription.getRemainingHours(timeManager: timeManager) {
            return "\(remainingHours)\(R.string.localizable.home_prescription_hours_suffix.key.localized)"
        } else if let remainingHours = prescription.getRemainingHours(timeManager: timeManager),
            remainingHours > 0,
            let remainingMins = prescription.getRemainingMins(timeManager: timeManager) {
            return "\(remainingMins)\(R.string.localizable.home_prescription_mins_suffix.key.localized)"
        } else {
            return ""
        }
    }
}
