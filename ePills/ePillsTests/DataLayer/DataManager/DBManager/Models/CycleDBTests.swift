//
//  CycleDBTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 15/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

@testable import ePills
import XCTest

class CycleDBTests: XCTestCase {

	var sut: CycleDB!

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		sut = CycleDB(medicineId: "aaa", unitsConsumed: 2, nextDose: 3)
	}

	func test_init() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertEqual(sut.medicineId, "aaa")
		XCTAssertEqual(sut.unitsConsumed, 2)
		XCTAssertEqual(sut.nextDose, 3)

		let cycle = sut.getCycle()
		XCTAssertEqual(cycle.id, sut.id)
		XCTAssertEqual(cycle.unitsConsumed, 2)
		XCTAssertEqual(cycle.nextDose, 3)

	}

	func test_initCycle() {
		let medicine = Medicine(name: "asdf", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		let medicineDB = MedicineDB(medicine: medicine)
		let cycle = Cycle(unitsConsumed: 1, nextDose: 2)
		sut = CycleDB(cycle: cycle, medicineId: medicineDB.id)

		XCTAssertEqual(sut.id.contains("-"), true)
		XCTAssertEqual(sut.id.contains("-"), true)
		XCTAssertEqual(sut.unitsConsumed, 1)
		XCTAssertEqual(sut.nextDose, 2)
		XCTAssertEqual(sut.medicineId, medicineDB.id)

	}

}
