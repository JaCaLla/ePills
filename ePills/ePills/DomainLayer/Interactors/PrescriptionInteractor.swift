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

    func add(medicine: Medicine)
   // func add(cycle: Cycle)
    //func remove(cycle: Cycle)
    func remove(medicine: Medicine)
    func update(medicine: Medicine)
    func takeDose(medicine: Medicine, onComplete: @escaping (Bool) -> Void)
    func getCurrentPrescriptionIndex()  -> AnyPublisher<Int, Never>
    func getMedicines() -> AnyPublisher<[Medicine], Never>
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
//        self.dataManager.getPrescriptions()
//            .sink { prescriptions in
//                self.cycles = prescriptions
//            }.store(in: &cancellables)
                self.dataManager.getMedicines()
                    .sink { medicines in
                        self.medicines = medicines
                    }.store(in: &cancellables)
    }
}

// MARK: - PrescriptionInteractorProtocol
extension PrescriptionInteractor: PrescriptionInteractorProtocol {
    
    func add(medicine: Medicine) {
        dataManager.add(medicine: medicine)
        if let index = medicines.firstIndex(of: medicine) {
            currentPrescriptionIndex = index
             currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        }
    }
//    func add(cycle: Cycle) {
//        dataManager.add(cycle: cycle)
//          if let index = cycles.firstIndex(of: cycle) {
//            currentPrescriptionIndex = index
//             currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
//        }
//    }

    func remove(medicine: Medicine) {
        LocalNotificationManager.shared.removeNotification(prescription: medicine)
        dataManager.remove(medicine: medicine)
        currentPrescriptionIndex = 0
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
    }
    
//    func remove(cycle: Cycle) {
//        LocalNotificationManager.shared.removeNotification(prescription: cycle)
//        dataManager.remove(prescription: cycle)
//        currentPrescriptionIndex = 0
//        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
//    }
    
//    func update(cycle: Cycle) {
////        dataManager.update(prescription: cycle)
////        if let index = cycles.firstIndex(of: cycle) {
////            currentPrescriptionIndex = index
////             currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
////        }
//    }
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

    func getCurrentPrescriptionIndex()  -> AnyPublisher<Int, Never> {
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        return currentPrescriptionIndexSubject.eraseToAnyPublisher()
    }

//    func getPrescriptions() -> AnyPublisher<[Cycle], Never> {
//        self.dataManager.getPrescriptions()
//            .sink { prescriptions in
//                self.cycles = prescriptions
//                self.subject.send(self.cycles)
//            }.store(in: &cancellables)
//        return subject.eraseToAnyPublisher()
//    }
    
    func getMedicines() -> AnyPublisher<[Medicine], Never> {
        self.dataManager.getMedicines()
            .sink { medicines in
                self.medicines = medicines
                self.subject.send(self.medicines)
            }.store(in: &cancellables)
        return subject.eraseToAnyPublisher()
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
