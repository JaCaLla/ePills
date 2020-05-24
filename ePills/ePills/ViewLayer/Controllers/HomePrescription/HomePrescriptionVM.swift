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
    func remove()
    func takeDose()
    func title() -> String
    func getIconName( timeManager: TimeManagerPrococol?) -> String
    func getMessage( timeManager: TimeManagerPrococol?) -> String
    func getRemainingTimeMessage( timeManager: TimeManagerPrococol?) -> (String, String)
    func updatable() -> Bool
    func getMessageColor(timeManager: TimeManagerPrococol?) -> String
}

public final class HomePrescriptionVM: ObservableObject {

    // MARK: - Public attributes
    private var view: HomePrescriptionView?

    // MARK: - Private attributes
    private var interactor: PrescriptionInteractorProtocol
    private var homeCoordinator: HomeCoordinatorProtocol
    internal var timeManager: TimeManagerPrococol

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var medicines: [Medicine] = []

    @Published var currentPage = 0
    @Published var currentPrescription: Medicine = Medicine(name: "", unitsBox: 0, intervalSecs:0, unitsDose: 0)
    @Published var prescriptionIcon: String = ""
    @Published var prescriptionMessage: String = ""
    @Published var remainingMessageMajor: String = ""
    @Published var remainingMessageMinor: String = ""
     @Published var prescriptionColor: String = ""
    @Published var isUpdatable: Bool = false
    
    var timer: Timer?
    var runCount = 0
    
    init(interactor: PrescriptionInteractorProtocol = PrescriptionInteractor(),
         homeCoordinator: HomeCoordinatorProtocol,
         timeManager: TimeManagerPrococol = TimeManager()) {
        self.interactor = interactor
        self.homeCoordinator = homeCoordinator
        self.timeManager = timeManager

        self.interactor.getMedicinesPublisher()
            .sink{ prescriptions in
                self.medicines = prescriptions
                self.refreshVM()
        }.store(in: &cancellables)
        self.interactor.getCurrentPrescriptionIndex()
            .sink { currentPrescriptionIndex in
                self.currentPage = currentPrescriptionIndex
                self.refreshVM()
        }.store(in: &cancellables)
        self.$medicines
            .sink { someValue in
                guard someValue.isEmpty else { return }
                self.homeCoordinator.replaceByFirstPrescription(interactor: self.interactor)
                self.refreshVM()
            }.store(in: &cancellables)
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
        self.isUpdatable = self.updatable()
        (self.remainingMessageMajor,self.remainingMessageMinor) = self.getRemainingTimeMessage(timeManager: timeManager)
        self.prescriptionColor = self.getMessageColor(timeManager: timeManager)
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
    
    func takeDose() {
        guard medicines.count > currentPage else { return }
        let medicine = self.medicines[currentPage]
        medicine.takeDose()
        self.interactor.takeDose(medicine: medicine, timeManager: TimeManager())
        self.refreshVM()
    }
    
    func title() -> String {
        guard medicines.count > currentPage else { return "" }
        let prescription = self.medicines[currentPage]
        return "\(prescription.name) [\(prescription.currentCycle.unitsConsumed)/\(prescription.unitsBox)]"
    }

    func getIconName(timeManager: TimeManagerPrococol?) -> String {
        guard medicines.count > currentPage else { return "" }
              let prescription = self.medicines[currentPage]
        switch prescription.getState(timeManager: timeManager ?? TimeManager()) {
        case .notStarted: return "stop"
        case .ongoing: return "play"
        case .ongoingReady: return "alarm"
        case .ongoingEllapsed: return "exclamationmark.triangle"
        case .finished: return "clear"
        }
    }

    func getMessage( timeManager: TimeManagerPrococol?) -> String {
        guard medicines.count > currentPage else { return ("") }
               let prescription = self.medicines[currentPage]
        
        print("\( prescription.getState(timeManager: timeManager ?? TimeManager()) )")
        let prescriptionState = prescription.getState(timeManager: timeManager ?? TimeManager())
        switch prescriptionState {
        case .notStarted: return R.string.localizable.home_prescription_not_started.key.localized
        case .ongoing: return R.string.localizable.home_prescription_onging.key.localized
        case .ongoingReady: return R.string.localizable.home_prescription_ongoing_ready.key.localized
        case .ongoingEllapsed: return R.string.localizable.home_prescription_ongoing_ellapsed.key.localized
        case .finished: return R.string.localizable.home_prescription_finished.key.localized
        }
    }

    func getRemainingTimeMessage( timeManager: TimeManagerPrococol?) -> (String, String) {
        guard medicines.count > currentPage else { return ("","") }
        let medicine = self.medicines[currentPage]
        
        guard let nextDose = medicine.getNextDose() else { return ("", "") }
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let tmpTimeManager = timeManager ?? TimeManager()
        let now: Date = Date(timeIntervalSince1970: TimeInterval(tmpTimeManager.timeIntervalSince1970()))
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
    
    func updatable() -> Bool {
        guard medicines.count > currentPage else { return false }
        let prescription = self.medicines[currentPage]
        let prescriptionState = prescription.getState()
        return prescriptionState == CyclesState.notStarted ||
         prescriptionState == CyclesState.finished

    }
    
    
    func getMessageColor(timeManager: TimeManagerPrococol?) -> String {
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
