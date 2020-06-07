//
//  DBManager.swift
//  seco
//
//  Created by Javier Calatrava on 28/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import RealmSwift

struct DBManagerError: Error { }

protocol DBManagerProtocol {
    
    func existMedicine() -> Bool
    
	func create(medicine: Medicine, timeManager: TimeManagerProtocol) -> Result<Medicine, Error>
	func delete(medicine: Medicine) -> Result<Bool, Error>
	func update(medicine: Medicine, timeManager: TimeManagerProtocol) -> Result<Medicine, Error>
	func getMedicines() -> [Medicine]

    func create(cycle: Cycle, medicineId: String, timeManager: TimeManagerProtocol) -> Result<Cycle, Error>
	func delete(cycle: Cycle) -> Result<Bool, Error>
	func updateCyle(cycle: Cycle) -> Result<Cycle, Error>
	func getCycles(medicineId: String) -> [Cycle]

	func create(dose: Dose, cycleId: String) -> Result<Dose, Error>
	func getDoses(cycleId: String) -> [Dose]
}

// MARK: - Resetable
class DBManager {

	static let shared = DBManager()
	var thread = Thread.current
	var realm: Realm!

	private init() {
		setRealmHandlers()
	}

	// MARK: - Medicine
    func isEmpty() -> Bool {
        self.resetHandlerIfNecessary()
        return realm.objects(MedicineDB.self).isEmpty
    }
    
	func create(medicine: Medicine, timeManager: TimeManagerProtocol) -> Result<Medicine, Error> {
		self.resetHandlerIfNecessary()
		if let medicineDB = self.getMedicineDB(id: medicine.id) {
            return self.updateDB(medicineDB: medicineDB, medicine: medicine, timeManager:timeManager)
		} else {
			do {
				let medicineDB = MedicineDB(medicine: medicine,timeManager: timeManager)
				try realm.write({
					self.realm.add(medicineDB)
				})
				return .success(medicineDB.getMedicine())
			} catch {
				return .failure(DBManagerError())
			}
		}
	}

	private func updateDB(medicineDB: MedicineDB, medicine: Medicine, timeManager: TimeManagerProtocol) -> Result<Medicine, Error> {
		self.resetHandlerIfNecessary()
		guard !(realm.objects(MedicineDB.self).isEmpty) else { return .failure(DBManagerError()) }
		do {
			try realm.write({
				medicineDB.id = medicine.id
				medicineDB.name = medicine.name
				medicineDB.unitsBox = medicine.unitsBox
				medicineDB.interval = medicine.intervalSecs
				medicineDB.unitsDose = medicine.unitsDose
				medicineDB.creation = medicine.creation
                medicineDB.update = timeManager.timeIntervalSince1970()
			})
			return .success(medicineDB.getMedicine())
		} catch {
			return .failure(DBManagerError())
		}
	}

	func delete(medicine: Medicine) -> Result<Bool, Error> {
		guard let medicinesDB = self.getMedicineDB(id: medicine.id) else {
			return .failure(DBManagerError())
		}
		let cyclesDB = realm.objects(CycleDB.self).filter({ $0.medicineId == medicine.id })
		let dosesDB: [DoseDB] = cyclesDB.map({ self.getDosesDB(cycleId: $0.id) }).flatMap { $0 }
		do {
			try realm.write({
				self.realm.delete(medicinesDB)
				self.realm.delete(cyclesDB)
				self.realm.delete(dosesDB)
			})
			return .success(true)
		} catch {
			return .failure(DBManagerError())
		}
	}

	func update(medicine: Medicine, timeManager: TimeManagerProtocol) -> Result<Medicine, Error> {
		self.resetHandlerIfNecessary()
		guard let medicineDB = self.getMedicineDB(id: medicine.id) else {
			return .failure(DBManagerError())
		}
        return updateDB(medicineDB: medicineDB, medicine: medicine, timeManager: timeManager)
	}

	func getMedicines() -> [Medicine] {
		self.resetHandlerIfNecessary()
		return realm.objects(MedicineDB.self).map({ $0.getMedicine() })
	}

	func getMedicineDB(id: String) -> MedicineDB? {
		self.resetHandlerIfNecessary()
		return realm.objects(MedicineDB.self).first(where: { $0.id == id })
	}

	// MARK: - Cycle
	func create(cycle: Cycle, medicineId: String, timeManager: TimeManagerProtocol) -> Result<Cycle, Error> {
		self.resetHandlerIfNecessary()
		if let cycleDB = self.getCycleDB(id: cycle.id) {
			return self.updateDB(cycleDB: cycleDB, cycle: cycle)
		} else {
			do {
                let cycleDB = CycleDB(cycle: cycle, medicineId: medicineId, timeManager: timeManager)
				try realm.write({
					self.realm.add(cycleDB)
				})
                let cycle = cycleDB.getCycle()
				return .success(cycle)
			} catch {
				return .failure(DBManagerError())
			}
		}
	}

	func delete(cycle: Cycle) -> Result<Bool, Error> {
		guard let cycleDB = self.getCycleDB(id: cycle.id) else {
			return .failure(DBManagerError())
		}
		let dosesDB = realm.objects(DoseDB.self).filter({ $0.cycleId == cycle.id })
		do {
			try realm.write({
				self.realm.delete(cycleDB)
				self.realm.delete(dosesDB)
			})
			return .success(true)
		} catch {
			return .failure(DBManagerError())
		}
	}

	func updateCyle(cycle: Cycle) -> Result<Cycle, Error> {
		self.resetHandlerIfNecessary()
		guard let cycleDB = self.getCycleDB(id: cycle.id) else {
			return .failure(DBManagerError())
		}
		return self.updateDB(cycleDB: cycleDB, cycle: cycle)
	}

	private func updateDB(cycleDB: CycleDB, cycle: Cycle) -> Result<Cycle, Error> {
		self.resetHandlerIfNecessary()
		guard !(realm.objects(CycleDB.self).isEmpty) else { return .failure(DBManagerError()) }
		do {
			try realm.write({
				cycleDB.medicineId = cycle.medicineId
				cycleDB.unitsConsumed = cycle.unitsConsumed
				if let nextDose = cycle.nextDose {
					cycleDB.nextDose = nextDose
				} else {
					cycleDB.nextDose = -1
				}
				cycleDB.update = cycle.update//Int(Date().timeIntervalSince1970)
                cycleDB.creation = cycle.creation
			})
            let cycle = cycleDB.getCycle()
			return .success(cycle)
		} catch {
			return .failure(DBManagerError())
		}
	}

	private func getCycleDB(id: String) -> CycleDB? {
		self.resetHandlerIfNecessary()
		return realm.objects(CycleDB.self).first(where: { $0.id == id })
	}

	func getCycles(medicineId: String) -> [Cycle] {
		self.resetHandlerIfNecessary()
		let seq = realm.objects(CycleDB.self).filter({ $0.medicineId == medicineId })
		let cycles: [Cycle] = seq.map({ $0.getCycle() })
		return cycles
	}

	// MARK: - Dose
	func create(dose: Dose, cycleId: String) -> Result<Dose, Error> {
		//     let medicineDB = MedicineDB(
		self.resetHandlerIfNecessary()
		guard self.getDoseDB(id: dose.id) == nil else {
			return .failure(DBManagerError())
		}
		do {
			let doseDB = DoseDB(dose: dose, cycleId: cycleId)
			try realm.write({
				self.realm.add(doseDB)
			})
			return .success(doseDB.getDose())
		} catch {
			return .failure(DBManagerError())
		}
	}

	private func getDoseDB(id: String) -> DoseDB? {
		self.resetHandlerIfNecessary()
		return realm.objects(DoseDB.self).first(where: { $0.id == id })
	}

	func getDosesDB(cycleId: String) -> [DoseDB] {
		self.resetHandlerIfNecessary()
		return realm.objects(DoseDB.self).filter({ $0.cycleId == cycleId })
	}

	func getDoses(cycleId: String) -> [Dose] {
		self.resetHandlerIfNecessary()
		let seq = realm.objects(DoseDB.self).filter({ $0.cycleId == cycleId })
		let doses: [Dose] = seq.map({ $0.getDose() })
		return doses
	}

	// MARK: - Handlers
	func resetHandlerIfNecessary() {
		guard thread == Thread.current else {
			self.setRealmHandlers()
			thread = Thread.current
			return
		}
	}

	func setRealmHandlers() {
		do {
			if NSClassFromString("XCTest") != nil {
				realm = try Realm(configuration: RealmConfig.utest.configuration)
			} else {
				realm = try Realm(configuration: RealmConfig.main.configuration)
			}
		} catch {
			// handle error
		}
	}
}

// MARK: - Resetable
extension DBManager: Resetable {
	func reset() {

		self.resetHandlerIfNecessary()
		do {
			try realm.write {
				realm.deleteAll()
			}
		} catch {
			// handle error
		}
	}
}

