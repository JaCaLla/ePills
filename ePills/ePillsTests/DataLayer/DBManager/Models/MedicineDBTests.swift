//
//  MedicineDBTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 15/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class MedicineDBTests: XCTestCase {

	var sut: MedicineDB!

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
		sut = MedicineDB(name: "aaa", unitsBox: 1, interval: 2, unitsDose: 3)
	}

	func test_init() throws {
		// This is an example of a functional test case.
		// Use XCTAssert and related functions to verify your tests produce the correct results.
		XCTAssertEqual(sut.name, "aaa")
		XCTAssertEqual(sut.unitsBox, 1)
		XCTAssertEqual(sut.interval, 2)
		XCTAssertEqual(sut.unitsDose, 3)

		sut.id = "xxxx"
		let medicine = sut.getMedicine()
		XCTAssertEqual(medicine.name, "aaa")
		XCTAssertEqual(medicine.unitsBox, 1)
		XCTAssertEqual(medicine.intervalSecs, 2)
		XCTAssertEqual(medicine.unitsDose, 3)
		XCTAssertEqual(medicine.id, "xxxx")
	}

	func test_initMedicine() {
		let medicine = Medicine(name: "asdf", unitsBox: 1, intervalSecs: 2, unitsDose: 3)
		sut = MedicineDB(medicine: medicine)

		XCTAssertEqual(sut.name, "asdf")
		XCTAssertEqual(sut.unitsBox, 1)
		XCTAssertEqual(sut.interval, 2)
		XCTAssertEqual(sut.unitsDose, 3)
		XCTAssertEqual(sut.id.contains("-"), true)

	}

}
