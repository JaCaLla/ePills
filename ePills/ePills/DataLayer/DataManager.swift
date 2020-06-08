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

    func isEmpty() -> Bool
    func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine?
    func remove(medicine: Medicine)
    func update(medicine: Medicine)
    func flushMedicines()
    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never>
    func add(dose: Dose, medicine: Medicine) -> Dose?
}

final class DataManager {

    static let shared: DataManager = DataManager()

    private let subject = PassthroughSubject < [Medicine], Never > ()
    private var medicines: [Medicine] = []

}

extension DataManager: DataManagerProtocol {
    func isEmpty() -> Bool {
        return DBManager.shared.isEmpty()
    }

    func add(dose: Dose, medicine: Medicine) -> Dose? {
        switch  DBManager.shared.create(dose: dose, cycleId: medicine.currentCycle.id) {
        case .success(let doseCreated):
                return doseCreated
            case .failure:
                return nil
        }
    }

    func add(medicine: Medicine,timeManager: TimeManagerProtocol) -> Medicine? {
        let cycle = Cycle(unitsConsumed: 0, nextDose: nil)
        guard let medicineCreated = createMedicine(medicine: medicine, timeManager:timeManager),
            let cycleCreated = createCycle(cyle: cycle, medicine: medicineCreated, timeManager: timeManager) else { return nil }

        medicineCreated.currentCycle = cycleCreated

        self.medicines = fetchStoredMedicines()

        subject.send(self.medicines)
        return medicineCreated
    }

    private func createMedicine(medicine: Medicine,timeManager: TimeManagerProtocol) -> Medicine? {
        switch DBManager.shared.create(medicine: medicine, timeManager: timeManager) {
        case .success(let medicineCreated):
            return medicineCreated
        case .failure:
            return nil
        }
    }

    private func createCycle(cyle: Cycle, medicine: Medicine, timeManager: TimeManagerProtocol) -> Cycle? {
        switch DBManager.shared.create(cycle: cyle, medicineId: medicine.id, timeManager: timeManager) {
        case .success(let cycleCreated):
            return cycleCreated
        case .failure:
            return nil
        }
    }

    //medicine: Medicine
    func update(medicine: Medicine) {
        guard let index = medicines.firstIndex(where: { $0.id == medicine.id }) else { return }
        medicines[index].name = medicine.name
        medicines[index].unitsBox = medicine.unitsBox
        medicines[index].intervalSecs = medicine.intervalSecs
        medicines[index].unitsDose = medicine.unitsDose
        //medicines[index].currentCycle = medicine.currentCycle //Cycle(name: medicine.name, unitsBox: medicine.unitsBox, intervalSecs: medicine.intervalSecs, unitsDose: medicine.unitsDose)
        medicines[index].creation = medicine.creation
        DBManager.shared.update(medicine: medicines[index], timeManager: TimeManager())

        let medicineCycles: [Cycle] = fetchCycles(medicineId: medicine.id)
        if let index = medicineCycles.firstIndex(where: { $0.id == medicine.currentCycle.id }) {
            //medicineCycles[index].medicineId = medicine.currentCycle.medicineId
            medicineCycles[index].unitsConsumed = medicine.currentCycle.unitsConsumed
            medicineCycles[index].nextDose = medicine.currentCycle.nextDose
            medicineCycles[index].creation = medicine.currentCycle.creation
            DBManager.shared.updateCyle(cycle: medicineCycles[index])
        }

        self.medicines = fetchStoredMedicines()
        subject.send(self.medicines)
    }

    func remove(medicine: Medicine) {
        DBManager.shared.delete(medicine: medicine)
        self.medicines = fetchStoredMedicines()
        //medicines.removeAll(where: {$0.id == medicine.id})
        // cycles.removeAll(where: {$0.id == medicine.currentCycle.id})
        subject.send(self.medicines)
    }
    
    func flushMedicines() {
       self.medicines = fetchStoredMedicines()
        subject.send(self.medicines)
    }

    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never> {
        self.medicines = fetchStoredMedicines()//medicines.sorted(by:{ $0.currentCycle.creation < $1.currentCycle.creation })
      //  subject.send(self.medicines)
        return subject.eraseToAnyPublisher()
    }

    internal func fetchStoredMedicines() -> [Medicine] {
        var medicines: [Medicine] = []
        DBManager.shared.getMedicines().forEach { medicine in
            var cycles = fetchCycles(medicineId: medicine.id).sorted(by: { $0.creation < $1.creation })
//            cycles.forEach { cycle in
//                if cycle.unitsConsumed >= medicine.unitsBox {
//                    medicine.pastCycles.append(cycle)
//                    medicine.pastCycles = medicine.pastCycles.sorted(by: { $0.creation > $1.creation})
//                } else {
//                    medicine.currentCycle = cycle
//                }
//            }
            if let lastCycle = cycles.last {
                medicine.currentCycle = lastCycle
                if cycles.count > 1 {
                    cycles.popLast()
                    medicine.pastCycles.append(contentsOf: cycles)
                } else {
                    medicine.pastCycles = []
                }
            } else {
                medicine.currentCycle = Cycle(unitsConsumed: 0, nextDose: nil)
                medicine.pastCycles = []
            }
            medicines.append(medicine)
        }
        return medicines
    }

    func fetchCycles(medicineId: String) -> [Cycle] {
        let cycles: [Cycle] = DBManager.shared.getCycles(medicineId: medicineId).map({
            $0.doses = fetchDoses(cycleId: $0.id)
            return $0
        })
        return cycles
    }

    func fetchDoses(cycleId: String) -> [Dose] {
        return DBManager.shared.getDoses(cycleId: cycleId).sorted(by: { $0.real < $1.real })
    }

}

extension DataManager: Resetable {
    func reset() {
        DBManager.shared.reset()
        self.medicines = []
        subject.send(self.medicines)
    }
}
