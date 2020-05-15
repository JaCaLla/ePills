//
//  DataManager.swift
//  seco
//
//  Created by Javier Calatrava on 25/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol DataManagerProtocol {
    
  //  func add(cycle: Cycle)
     func add(medicine: Medicine)
    func remove(medicine: Medicine)
    //func remove(prescription: Cycle)
   // func update(prescription: Cycle)
     func update(medicine: Medicine)
   // func getPrescriptions() -> AnyPublisher<[Cycle], Never>
    func getMedicines() -> AnyPublisher<[Medicine], Never>
}

final class DataManager {

    static let shared:DataManager = DataManager()
    
    private let subject = PassthroughSubject< [Medicine], Never>()
  //  private var cycles: [Cycle] = []
    private var medicines: [Medicine] = []

}

extension DataManager: DataManagerProtocol {
    
//    func add(cycle: Cycle) {
//        cycles.append(cycle)
//        cycles = cycles.sorted(by:{ $0.creation < $1.creation })
//        subject.send(self.cycles)
//    }
    
    func add(medicine: Medicine) {
        medicines.append(medicine)
       // cycles.append(medicine.currentCycle)
        medicines = medicines.sorted(by:{ $0.currentCycle.creation < $1.currentCycle.creation })
        subject.send(self.medicines)
    }

    func remove(medicine: Medicine) {
        medicines.removeAll(where: {$0.id == medicine.id})
       // cycles.removeAll(where: {$0.id == medicine.currentCycle.id})
        subject.send(self.medicines)
    }
    
//    func remove(prescription: Cycle) {
//
//        cycles.removeAll(where: {$0.id == prescription.id})
//        subject.send(self.cycles)
//    }
    
    func getMedicines() -> AnyPublisher<[Medicine], Never> {
        medicines = medicines.sorted(by:{ $0.currentCycle.creation < $1.currentCycle.creation })
        subject.send(self.medicines)
        return subject.eraseToAnyPublisher()
    }
//    func getPrescriptions() -> AnyPublisher<[Cycle], Never> {
//        cycles = cycles.sorted(by:{ $0.creation < $1.creation })
//        subject.send(self.cycles)
//        return subject.eraseToAnyPublisher()
//    }
    
//    func update(prescription: Cycle) {
//        guard let index = cycles.firstIndex(where: {$0.id == prescription.id}) else { return }
//        cycles[index].name = prescription.name
//        cycles[index].unitsBox = prescription.unitsBox
//        cycles[index].intervalSecs = prescription.intervalSecs
//        cycles[index].unitsDose = prescription.unitsDose
//        cycles[index].unitsConsumed = prescription.unitsConsumed
//        cycles[index].nextDose = prescription.nextDose
//        cycles[index].creation = prescription.creation
//
//        subject.send(self.medicines)
//    }
    //medicine: Medicine
    func update(medicine: Medicine) {
        guard let index = medicines.firstIndex(where: {$0.id == medicine.id}) else { return }
        medicines[index].name = medicine.name
        medicines[index].unitsBox = medicine.unitsBox
        medicines[index].intervalSecs = medicine.intervalSecs
        medicines[index].unitsDose = medicine.unitsDose
        medicines[index].currentCycle = medicine.currentCycle //Cycle(name: medicine.name, unitsBox: medicine.unitsBox, intervalSecs: medicine.intervalSecs, unitsDose: medicine.unitsDose)
        medicines[index].creation = medicine.creation

        subject.send(self.medicines)
    }
}

extension DataManager: Resetable {
    func reset() {
        self.medicines = []
        subject.send(self.medicines)
    }
}
