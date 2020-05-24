//
//  PrescriptionInteractor.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol PrescriptionInteractorProtocol {

    func add(medicine: Medicine) -> Medicine?
   // func add(cycle: Cycle)
    //func remove(cycle: Cycle)
    func remove(medicine: Medicine)
    func update(medicine: Medicine)
    func takeDose(medicine: Medicine, onComplete: @escaping (Bool) -> Void)
     func takeDose(medicine: Medicine, timeManager: TimeManagerPrococol)
    func getCurrentPrescriptionIndex()  -> AnyPublisher<Int, Never>
    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never>
     func flushMedicines()
    func getIntervals() -> [Interval] 
}


final class PrescriptionInteractor {

    // MARK: - Read only attributes
    private(set) var dataManager: DataManagerProtocol

    // MARK: - Private attributes
  //  /*@Published*/ private/*(set)*/ var cycles: [Cycle] = []
      /*@Published*/ private/*(set)*/ var medicines: [Medicine] = []
    private let subject = PassthroughSubject< [Medicine], Never>()
    private let currentPrescriptionIndexSubject = PassthroughSubject< Int, Never>()
    private var cancellables = Set<AnyCancellable>()
    private var currentPrescriptionIndex: Int = 0

    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager

                self.dataManager.getMedicinesPublisher()
                    .sink { medicines in
                        self.medicines = medicines
                        self.subject.send(self.medicines)
                    }.store(in: &cancellables)
    }
}

// MARK: - PrescriptionInteractorProtocol
extension PrescriptionInteractor: PrescriptionInteractorProtocol {
    
    func add(medicine: Medicine) -> Medicine? {
        guard let createdMedicine = dataManager.add(medicine: medicine) else { return nil}
        if let index = medicines.firstIndex(of: createdMedicine) {
            currentPrescriptionIndex = index
             currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        }
        return createdMedicine
    }
    func remove(medicine: Medicine) {
        LocalNotificationManager.shared.removeNotification(prescription: medicine)
        dataManager.remove(medicine: medicine)
        currentPrescriptionIndex = 0
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
    }
    
    func update(medicine: Medicine) {
                dataManager.update(medicine: medicine)
                if let index = medicines.firstIndex(of: medicine) {
                    currentPrescriptionIndex = index
                     currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
                }
    }
    
    func takeDose(medicine: Medicine, onComplete: @escaping (Bool) -> Void) {
        if !medicine.isLast() {
           LocalNotificationManager.shared.addNotification(prescription: medicine, onComplete: onComplete)
        }

        self.update(medicine: medicine)
    }
    
    func takeDose(medicine: Medicine,timeManager: TimeManagerPrococol) {
        
        if !medicine.isLast() {
            LocalNotificationManager.shared.addNotification(prescription: medicine, onComplete: { _ in /* Do nothing */})
        }
        medicine.takeDose(timeManager:timeManager)
        if let nextDose =  medicine.currentCycle.nextDose {
            let dose = Dose(expected: nextDose, timeManager: timeManager)
            dataManager.add(dose: dose, medicine: medicine)
        }
        
         self.update(medicine: medicine)
    }

    func getCurrentPrescriptionIndex()  -> AnyPublisher<Int, Never> {
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        return currentPrescriptionIndexSubject.eraseToAnyPublisher()
    }
    
    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never> {
        self.dataManager.getMedicinesPublisher()
            .sink { medicines in
                self.medicines = medicines
             //   self.subject.send(self.medicines)
            }.store(in: &cancellables)
        return subject.eraseToAnyPublisher()
    }
    
    func flushMedicines() {
         self.dataManager.flushMedicines()
    }
    
    func getIntervals() -> [Interval] {
        
        let secsPerHour = 3600
        
        var invervals: [Interval] = []
        invervals.append(Interval(secs: 30, label: "_30 Secs"))
        invervals.append(Interval(secs: 1 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_1_hour.key.localized))
        invervals.append(Interval(secs: 2 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_2_hours.key.localized))
        invervals.append(Interval(secs: 4 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_4_hours.key.localized))
        invervals.append(Interval(secs: 6 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_6_hours.key.localized))
        invervals.append(Interval(secs: 8 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_8_hours.key.localized))
        invervals.append(Interval(secs: 12 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_12_hours.key.localized))
        invervals.append(Interval(secs: 24 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_1_day.key.localized))
        invervals.append(Interval(secs: 48 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_2_days.key.localized))
        
        return invervals
    }
}
