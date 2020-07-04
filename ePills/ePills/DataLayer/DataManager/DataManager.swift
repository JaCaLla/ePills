//
//  DataManager.swift
//  seco
//
//  Created by Javier Calatrava on 25/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit

enum DataManagerError: Error {
    case pictureNotFound
    case pictureNotStored
}

protocol DataManagerProtocol {

    func isEmpty() -> Bool
    @discardableResult func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine?
    func remove(medicine: Medicine)
    func update(medicine: Medicine)
    func flushMedicines()
    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never>
    func add(dose: Dose, medicine: Medicine) -> Dose?
    func getMedicinePicture(medicine: Medicine) -> Future<UIImage, DataManagerError>
    func setMedicinePicture(medicine: Medicine, picture: UIImage ) -> Future<Bool, DataManagerError>
}

final class DataManager {

    static let shared: DataManager = DataManager()

    // MARK: - Private attributes
    private let subject = PassthroughSubject <[Medicine], Never>()
    private var medicines: [Medicine] = []

    // MARK: - Public attributes
    var localFileManager: LocalFileManagerProtocol = LocalFileManager.shared

}

extension DataManager: DataManagerProtocol {
    func isEmpty() -> Bool {
        return DBManager.shared.isEmpty()
    }

    func add(dose: Dose, medicine: Medicine) -> Dose? {
        switch DBManager.shared.create(dose: dose, cycleId: medicine.currentCycle.id) {
        case .success(let doseCreated):
            return doseCreated
        case .failure:
            return nil
        }
    }

    @discardableResult func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine? {
        let cycle = Cycle(unitsConsumed: 0, nextDose: nil)
        guard let medicineCreated = createMedicine(medicine: medicine, timeManager: timeManager),
            let cycleCreated = createCycle(cyle: cycle, medicine: medicineCreated, timeManager: timeManager) else {
                return nil
        }

        medicineCreated.currentCycle = cycleCreated
        self.medicines = fetchStoredMedicines()
        subject.send(self.medicines)
        return medicineCreated
    }

    private func createMedicine(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine? {
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
        medicines[index].creation = medicine.creation
        medicines[index].pictureFilename = medicine.pictureFilename
        DBManager.shared.update(medicine: medicines[index], timeManager: TimeManager())

        let medicineCycles: [Cycle] = fetchCycles(medicineId: medicine.id)
        if let index = medicineCycles.firstIndex(where: { $0.id == medicine.currentCycle.id }) {
            medicineCycles[index].unitsConsumed = medicine.currentCycle.unitsConsumed
            medicineCycles[index].nextDose = medicine.currentCycle.nextDose
            medicineCycles[index].creation = medicine.currentCycle.creation
            DBManager.shared.updateCyle(cycle: medicineCycles[index])
        }

        self.medicines = fetchStoredMedicines()
        subject.send(self.medicines)
    }

    func remove(medicine: Medicine) {
        _ = DBManager.shared.delete(medicine: medicine)
        self.medicines = fetchStoredMedicines()
        if let uwpPictureFilename = medicine.pictureFilename {
            LocalFileManager.shared.remove(filename: uwpPictureFilename)
        }
        subject.send(self.medicines)
    }

    func flushMedicines() {
        self.medicines = fetchStoredMedicines()
        subject.send(self.medicines)
    }

    func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never> {
        self.medicines = fetchStoredMedicines()
        return subject.eraseToAnyPublisher()
    }

    internal func fetchStoredMedicines() -> [Medicine] {
        var medicines: [Medicine] = []
        DBManager.shared.getMedicines().forEach { medicine in
            var cycles = fetchCycles(medicineId: medicine.id).sorted(by: { $0.creation < $1.creation })
            if let lastCycle = cycles.last {
                medicine.currentCycle = lastCycle
                if cycles.count > 1 {
                    _ = cycles.popLast()
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

    func getMedicinePicture(medicine: Medicine) -> Future<UIImage, DataManagerError> {
        // guard let pictureFilename = medicine.pictureFilename else { return }
        return Future<UIImage, DataManagerError> { [weak self] promise in
            if let weakSelf = self,
                let pictureFilename = medicine.pictureFilename {
                weakSelf.localFileManager.loadImage(fileName: pictureFilename, onComplete: { image in
                    if let storedImage = image {
                        promise(.success(storedImage))
                    } else {
                        promise(.failure(.pictureNotFound))
                    }
                })
            } else {
                promise(.failure(.pictureNotFound))
            }
        }
    }
    
    func setMedicinePicture(medicine: Medicine, picture: UIImage ) -> Future<Bool, DataManagerError> {
        return Future<Bool, DataManagerError> { [weak self] promise in
            guard let weakSelf = self,
                  let pictureFilename = medicine.pictureFilename else {
                promise(.failure(.pictureNotStored))
                return
            }
            weakSelf.localFileManager.saveImage(imageName: pictureFilename, image: picture) { result in
                result ?  promise(.success(result)) : promise(.failure(.pictureNotStored))
            }
        }
    }

}

extension DataManager: Resetable {
    func reset() {
        LocalFileManager.shared.reset()
        DBManager.shared.reset()
        self.medicines = []
        subject.send(self.medicines)
    }
}
