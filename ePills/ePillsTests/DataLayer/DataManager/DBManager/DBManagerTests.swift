//
//  DBManagerTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 15/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class DBManagerTests: XCTestCase {

	var sut: DBManager!

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		sut = DBManager.shared
		sut.reset()
	}

	override func tearDownWithError() throws {
		sut = DBManager.shared
		sut.reset()
	}

	// MARK: - Medicine
    
    func tests_existMedicine() {
        //Given
        let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
        let result = sut.create(medicine: medicine, timeManager: TimeManager())
        switch result {
        case .success(let medicine1):
            let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
            let result = sut.create(medicine: medicine, timeManager: TimeManager())
            switch result {
            case .success(let medicine2):
                // When
                switch sut.delete(medicine: medicine1) {
                case .success:
                    // Then
                    guard let first = self.sut.getMedicines().first,
                        self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
                    XCTAssertEqual(first.name, "bbbb")
                    XCTAssertEqual(first.unitsBox, 10)
                    XCTAssertEqual(first.intervalSecs, 20)
                    XCTAssertEqual(first.unitsDose, 30)
                    XCTAssertEqual(first.id, medicine2.id)

                    switch sut.delete(medicine: medicine2) {
                    case .success:
                        // Then
                        XCTAssertTrue(sut.isEmpty())
                    default:
                        XCTFail("\(#function)")
                    }
                default:
                    XCTFail("\(#function)")
                }
            case .failure:
                XCTFail("\(#function)")
            }
        case .failure:
            XCTFail("\(#function)")
        }
    }

	func test_createMedicine() throws {
		let medicine = Medicine(name: "asdf", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		let result = sut.create(medicine: medicine, timeManager: TimeManager())

		switch result {
		case .success(let medicine):
			XCTAssertEqual(medicine.name, "asdf")
			XCTAssertEqual(medicine.unitsBox, 1)
			XCTAssertEqual(medicine.intervalSecs, 2)
			XCTAssertEqual(medicine.unitsDose, 3)
			XCTAssertEqual(medicine.id.contains("-"), true)
			let medicines = self.sut.getMedicines()
			guard let first = medicines.first,
				medicines.count == 1 else {
					XCTFail("\(#function)")
					return
			}
			XCTAssertEqual(first.name, "asdf")
			XCTAssertEqual(first.unitsBox, 1)
			XCTAssertEqual(first.intervalSecs, 2)
			XCTAssertEqual(first.unitsDose, 3)
			XCTAssertEqual(first.id, medicine.id)
		case .failure:
			XCTFail("\(#function)")
		}
	}

	func test_createMedicineWhenExists() throws {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let medicineNew = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
			// When
			medicineNew.id = medicine.id
			switch sut.create(medicine: medicineNew, timeManager: TimeManager()) {
			case .success(let medicine):
				// Then
				XCTAssertEqual(medicine.name, "bbbb")
				XCTAssertEqual(medicine.unitsBox, 10)
				XCTAssertEqual(medicine.intervalSecs, 20)
				XCTAssertEqual(medicine.unitsDose, 30)
				XCTAssertEqual(medicine.id.contains("-"), true)

				let medicines = self.sut.getMedicines()
				guard let first = medicines.first,
					medicines.count == 1 else {
						XCTFail("\(#function)")
						return
				}
				XCTAssertEqual(first.name, "bbbb")
				XCTAssertEqual(first.unitsBox, 10)
				XCTAssertEqual(first.intervalSecs, 20)
				XCTAssertEqual(first.unitsDose, 30)
				XCTAssertEqual(first.id, medicine.id)

			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_createMedicineWhenDoNotExists() throws {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success:
			let medicineNew = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
			// When
			//medicineNew.id = medicine.id // ID must be different
			switch sut.create(medicine: medicineNew, timeManager: TimeManager()) {
			case .success(let medicine):
				// Then
				XCTAssertEqual(medicine.name, "bbbb")
				XCTAssertEqual(medicine.unitsBox, 10)
				XCTAssertEqual(medicine.intervalSecs, 20)
				XCTAssertEqual(medicine.unitsDose, 30)
				XCTAssertEqual(medicine.id.contains("-"), true)

				let medicines = self.sut.getMedicines()
				guard let first = medicines.first,
					let last = medicines.last,
					medicines.count == 2 else {
						XCTFail("\(#function)")
						return
				}
				XCTAssertEqual(first.name, "aaaa")
				XCTAssertEqual(first.unitsBox, 1)
				XCTAssertEqual(first.intervalSecs, 2)
				XCTAssertEqual(first.unitsDose, 3)
				XCTAssertNotEqual(first.id, medicine.id)

				XCTAssertEqual(last.name, "bbbb")
				XCTAssertEqual(last.unitsBox, 10)
				XCTAssertEqual(last.intervalSecs, 20)
				XCTAssertEqual(last.unitsDose, 30)
				XCTAssertEqual(last.id, medicine.id)

				XCTAssertNotEqual(last.id, first.id)

			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_deleteTwoMedicines() throws {
		//Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		let result = sut.create(medicine: medicine, timeManager: TimeManager())
		switch result {
		case .success(let medicine1):
			let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
			let result = sut.create(medicine: medicine, timeManager: TimeManager())
			switch result {
			case .success(let medicine2):
				// When
				switch sut.delete(medicine: medicine1) {
				case .success:
					// Then
					guard let first = self.sut.getMedicines().first,
						self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
					XCTAssertEqual(first.name, "bbbb")
					XCTAssertEqual(first.unitsBox, 10)
					XCTAssertEqual(first.intervalSecs, 20)
					XCTAssertEqual(first.unitsDose, 30)
					XCTAssertEqual(first.id, medicine2.id)

					switch sut.delete(medicine: medicine2) {
					case .success:
						// Then
						guard self.sut.getMedicines().isEmpty else { XCTFail("\(#function)"); return }
					default:
						XCTFail("\(#function)")
					}
				default:
					XCTFail("\(#function)")
				}
			case .failure:
				XCTFail("\(#function)")
			}
		case .failure:
			XCTFail("\(#function)")
		}
	}

	func test_deleteNotExistingMedicine() throws {
		//Given
		let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
		let result = sut.create(medicine: medicine, timeManager: TimeManager())
		switch result {
		case .success(let medicine1):
			// When
			medicine.id = "0"
			switch sut.delete(medicine: medicine) {
			case .success:
				// Then
				XCTFail("\(#function)")
			case .failure:
				guard let first = self.sut.getMedicines().first,
					self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
				XCTAssertEqual(first.name, "bbbb")
				XCTAssertEqual(first.unitsBox, 10)
				XCTAssertEqual(first.intervalSecs, 20)
				XCTAssertEqual(first.unitsDose, 30)
				XCTAssertEqual(first.id, medicine1.id)
			}
		case .failure:
			XCTFail("\(#function)")
		}
	}

	func test_deleteMedicineWithCycleAndDose() throws {
		// Given
        let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
        switch sut.create(medicine: medicine, timeManager: TimeManager()) {
        case .success(let medicineCreated):
            let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
            switch sut.create(cycle: cycle, medicineId: medicineCreated.id, timeManager: TimeManager()) {
            case .success(let cycleCreated):
                let timeManager = TimeManager()
                timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 20))
                let dose = Dose(expected: 22, timeManager: timeManager)
                switch sut.create(dose: dose, cycleId: cycleCreated.id) {
                case .success:
                    switch sut.delete(medicine: medicineCreated) {
                    case .success:
                        guard self.sut.getMedicines().count == 0 else {
                             XCTFail("\(#function)")
                             return
                         }
                        guard self.sut.getCycles(medicineId: medicineCreated.id).count == 0 else {
                            XCTFail("\(#function)")
                            return
                        }
                        guard self.sut.getDoses(cycleId: cycle.id).count == 0 else {
                            XCTFail("\(#function)")
                            return
                        }
                    case .failure:
                        XCTFail("\(#function)")
                    }
                case .failure: XCTFail("\(#function)")
                }
            case .failure: XCTFail("\(#function)")
            }
        default: XCTFail("\(#function)")
        }
	}

	func test_deleteUpdatedMedicine() {
		// Given
        let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
        switch sut.create(medicine: medicine, timeManager: TimeManager()) {
        case .success(let medicineCreated):
            let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
            switch sut.create(cycle: cycle, medicineId: medicineCreated.id, timeManager: TimeManager()) {
            case .success(let cycleCreated):
                let timeManager = TimeManager()
                timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 20))
                let dose = Dose(expected: 22, timeManager: timeManager)
                switch sut.create(dose: dose, cycleId: cycleCreated.id) {
                case .success:
                    let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
                    // When
                    medicine.id = medicineCreated.id
                    switch sut.update(medicine: medicine,timeManager: TimeManager()) {
                    case .success(let medicine2):
                        guard let first = self.sut.getMedicines().first,
                            self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
                        XCTAssertEqual(first.name, "bbbb")
                        XCTAssertEqual(first.unitsBox, 10)
                        XCTAssertEqual(first.intervalSecs, 20)
                        XCTAssertEqual(first.unitsDose, 30)
                        XCTAssertEqual(first.id, medicine2.id)

                        guard self.sut.getMedicines().count == 1 else {
                             XCTFail("\(#function)")
                             return
                         }
                        guard self.sut.getCycles(medicineId: medicineCreated.id).count == 1 else {
                            XCTFail("\(#function)")
                            return
                        }
                        guard self.sut.getDoses(cycleId: cycleCreated.id).count == 1 else {
                            XCTFail("\(#function)")
                            return
                        }
                    case .failure:
                        XCTFail("\(#function)")
                    }
                    case .failure:
                        XCTFail("\(#function)")
                    }
                case .failure: XCTFail("\(#function)")
                }
            case .failure: XCTFail("\(#function)")
            }
        //case .failure: XCTFail("\(#function)")
        //}
	}

	func test_updateMedicine() {
		//Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		let result = sut.create(medicine: medicine, timeManager: TimeManager())
		switch result {
		case .success(let medicine1):
			let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
			// When
			medicine.id = medicine1.id
			switch sut.update(medicine: medicine,timeManager: TimeManager()) {
			case .success(let medicine2):
				// Then
				guard let first = self.sut.getMedicines().first,
					self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
				XCTAssertEqual(first.name, "bbbb")
				XCTAssertEqual(first.unitsBox, 10)
				XCTAssertEqual(first.intervalSecs, 20)
				XCTAssertEqual(first.unitsDose, 30)
				XCTAssertEqual(first.id, medicine2.id)
			case .failure:
				XCTFail("\(#function)")
			}
		case .failure:
			XCTFail("\(#function)")
		}
	}

	func test_updateNotExistingMedicine() {
		//Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		let result = sut.create(medicine: medicine, timeManager: TimeManager())
		switch result {
		case .success(let medicine2):
			let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
			// When
			medicine.id = "xxx"
			switch sut.update(medicine: medicine, timeManager: TimeManager()) {
			case .success:
				XCTFail("\(#function)")
			case .failure:
				// Then
				guard let first = self.sut.getMedicines().first,
					self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
				XCTAssertEqual(first.name, "aaaa")
				XCTAssertEqual(first.unitsBox, 1)
				XCTAssertEqual(first.intervalSecs, 2)
				XCTAssertEqual(first.unitsDose, 3)
				XCTAssertEqual(first.id, medicine2.id)
			}
		case .failure:
			XCTFail("\(#function)")
		}
	}

	func test_updateMedicineWithCycleAndDose() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicineCreated):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicineCreated.id, timeManager: TimeManager()) {
			case .success(let cycle):
				let timeManager = TimeManager()
				timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 20))
				let dose = Dose(expected: 22, timeManager: timeManager)
				switch sut.create(dose: dose, cycleId: cycle.id) {
				case .success(let dose):
					// Then
					let medicine = Medicine(name: "bbbb", unitsBox: 10, intervalSecs: 20, unitsDose: 30)
					// When
					medicine.id = medicineCreated.id
					switch sut.update(medicine: medicine, timeManager: TimeManager()) {
					case .success(let medicine2):
						// Then
						guard let first = self.sut.getMedicines().first,
							self.sut.getMedicines().count == 1 else { XCTFail("\(#function)"); return }
						XCTAssertEqual(first.name, "bbbb")
						XCTAssertEqual(first.unitsBox, 10)
						XCTAssertEqual(first.intervalSecs, 20)
						XCTAssertEqual(first.unitsDose, 30)
						XCTAssertEqual(first.id, medicine2.id)
						guard self.sut.getCycles(medicineId: medicineCreated.id).count == 1 else {
							XCTFail("\(#function)")
							return
						}
						guard self.sut.getDoses(cycleId: cycle.id).count == 1 else {
							XCTFail("\(#function)")
							return
						}

					case .failure:
						XCTFail("\(#function)")
					}

				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	// MARK: - Cycle
	func test_createTwoCyles() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let cycle1):
				// Then
				XCTAssertEqual(cycle1.id.contains("-"), true)
				XCTAssertEqual(cycle1.medicineId, medicine.id)
				XCTAssertEqual(cycle1.unitsConsumed, 5)
				XCTAssertEqual(cycle1.nextDose, 15)

				let cycle = Cycle(unitsConsumed: 3, nextDose: nil)
				switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
				case .success(let cycle2):
					// Then
					XCTAssertEqual(cycle2.id.contains("-"), true)
					XCTAssertEqual(cycle2.medicineId, medicine.id)
					XCTAssertEqual(cycle2.unitsConsumed, 3)
					XCTAssertNil(cycle2.nextDose)
					guard self.sut.getCycles(medicineId: medicine.id).count == 2 else {
						XCTFail("\(#function)")
						return
					}
				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_createAnExistingCycle() throws {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let cycle1):
				// Then
				XCTAssertEqual(cycle1.id.contains("-"), true)
				XCTAssertEqual(cycle1.medicineId, medicine.id)
				XCTAssertEqual(cycle1.unitsConsumed, 5)
				XCTAssertEqual(cycle1.nextDose, 15)

				let cycle = Cycle(unitsConsumed: 3, nextDose: nil)
				cycle.id = cycle1.id
				cycle.medicineId = medicine.id
				switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
				case .success(let cycle2):
					// Then
					XCTAssertEqual(cycle2.id.contains("-"), true)
					XCTAssertEqual(cycle2.medicineId, medicine.id)
					XCTAssertEqual(cycle2.unitsConsumed, 3)
					XCTAssertNil(cycle2.nextDose)
					guard self.sut.getCycles(medicineId: medicine.id).count == 1 else {
						XCTFail("\(#function)")
						return
					}
				case .failure:
					XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_deleteCycle() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let cycle1):
				let cycle = Cycle(unitsConsumed: 3, nextDose: nil)
				switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
				case .success(let cycle2):
					guard self.sut.getCycles(medicineId: medicine.id).count == 2 else {
						XCTFail("\(#function)")
						return
					}
					switch self.sut.delete(cycle: cycle1) {
					case .success:
						guard self.sut.getCycles(medicineId: medicine.id).count == 1 else {
							XCTFail("\(#function)")
							return
						}
						switch self.sut.delete(cycle: cycle2) {
						case .success:
							guard self.sut.getCycles(medicineId: medicine.id).count == 0 else {
								XCTFail("\(#function)")
								return
							}
						case .failure: XCTFail("\(#function)")
						}
					case .failure: XCTFail("\(#function)")
					}
				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_deleteNotExistingCycle() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 3, nextDose: nil)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success:
				// When
				cycle.id = "xxxx"
				switch self.sut.delete(cycle: cycle) {
				case .success:
					XCTFail("\(#function)")
				case .failure:
					break
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_deleteCycleWithDose() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let cycle):
				let timeManager = TimeManager()
				timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 20))
				let dose = Dose(expected: 22, timeManager: timeManager)
				switch sut.create(dose: dose, cycleId: cycle.id) {
				case .success(let dose):
					// When
					switch self.sut.delete(cycle: cycle) {
					case .success:
						// Then
						guard self.sut.getCycles(medicineId: medicine.id).count == 0 else {
							XCTFail("\(#function)")
							return
						}
						guard self.sut.getDoses(cycleId: cycle.id).count == 0 else {
							XCTFail("\(#function)")
							return
						}
					case .failure: XCTFail("\(#function)")
					}

				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_updateCycle() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 3, nextDose: nil)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let createdCycle):
				let cycle = Cycle(unitsConsumed: 11, nextDose: 33)
				cycle.id = createdCycle.id
				cycle.medicineId = createdCycle.medicineId
				switch self.sut.updateCyle(cycle: cycle) {
				case .success(let cycle):
					XCTAssertEqual(cycle.id.contains("-"), true)
					XCTAssertEqual(cycle.medicineId, medicine.id)
					XCTAssertEqual(cycle.unitsConsumed, 11)
					XCTAssertEqual(cycle.nextDose, 33)
				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_updateCycleDoesNotExist() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 3, nextDose: nil)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let createdCycle):
				let cycle = Cycle(unitsConsumed: 11, nextDose: 33)
				cycle.id = "xxx"
				cycle.medicineId = createdCycle.medicineId
				switch self.sut.updateCyle(cycle: cycle) {
				case .success:
					XCTFail("\(#function)")
				case .failure:
					break
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_updateCycleWithDose() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let createdCycle):
				let timeManager = TimeManager()
				timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 20))
				let dose = Dose(expected: 22, timeManager: timeManager)
				switch sut.create(dose: dose, cycleId: cycle.id) {
				case .success(let dose):
					let cycle = Cycle(unitsConsumed: 11, nextDose: 33)
					cycle.id = createdCycle.id
					cycle.medicineId = createdCycle.medicineId
					switch self.sut.updateCyle(cycle: cycle) {
					case .success(let cycle):
						XCTAssertEqual(cycle.id.contains("-"), true)
						XCTAssertEqual(cycle.medicineId, medicine.id)
						XCTAssertEqual(cycle.unitsConsumed, 11)
						XCTAssertEqual(cycle.nextDose, 33)
					case .failure: XCTFail("\(#function)")
					}
				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	// MARK: - Dose
	func test_createDose() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let cycle):
				let timeManager = TimeManager()
				timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 20))
				let dose = Dose(expected: 22, timeManager: timeManager)
				switch sut.create(dose: dose, cycleId: cycle.id) {
				case .success(let dose):
					// Then
					XCTAssertEqual(dose.id.contains("-"), true)
					XCTAssertEqual(dose.cycleId, cycle.id)
					XCTAssertEqual(dose.expected, 22)
					XCTAssertEqual(dose.real, 20)
					guard self.sut.getDoses(cycleId: cycle.id).count == 1 else {
						XCTFail("\(#function)")
						return
					}
				case .failure: XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

	func test_createExistingDose() {
		// Given
		let medicine = Medicine(name: "aaaa", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		switch sut.create(medicine: medicine, timeManager: TimeManager()) {
		case .success(let medicine):
			let cycle = Cycle(unitsConsumed: 5, nextDose: 15)
			switch sut.create(cycle: cycle, medicineId: medicine.id, timeManager: TimeManager()) {
			case .success(let cycle):
				let dose = Dose(expected: 22)
				switch sut.create(dose: dose, cycleId: cycle.id) {
				case .success(let doseCreated):
					let dose = Dose(expected: 88)
					dose.id = doseCreated.id
					dose.cycleId = doseCreated.cycleId
					switch sut.create(dose: dose, cycleId: cycle.id) {
					case .success: XCTFail("\(#function)")
					case .failure:
						guard self.sut.getDoses(cycleId: cycle.id).count == 1 else {
							XCTFail("\(#function)")
							return
						}
					}
				case .failure:
					XCTFail("\(#function)")
				}
			case .failure: XCTFail("\(#function)")
			}
		default: XCTFail("\(#function)")
		}
	}

}
