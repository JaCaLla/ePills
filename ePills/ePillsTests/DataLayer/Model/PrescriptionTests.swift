//
//  PrescriptionTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 26/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class PrescriptionTests: XCTestCase {

    var sut: Prescription!

    override func setUpWithError() throws {

        sut = Prescription(name: "asdfg",
                           unitsBox: 20,
                           interval: Interval(hours: 8, label: "8 hours"),
                           unitsDose: 2)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_defaultConstructor() throws {
        XCTAssertEqual(sut.name, "asdfg")
        XCTAssertEqual(sut.unitsBox, 20)
        XCTAssertEqual(sut.interval, Interval(hours: 8, label: "8 hours"))
        XCTAssertEqual(sut.unitsDose, 2)
        XCTAssertEqual(sut.getState(), .notStarted)
        XCTAssertEqual(sut.unitsConsumed, 0)
        XCTAssertNil(sut.nextDose)
    }
    
    func test_prescriptionStarted() {
        // When
        let now = Int(Date().timeIntervalSince1970)
        sut.takeDose()
        // Then
        XCTAssertEqual(sut.getState(), .ongoing)
        XCTAssertEqual(sut.unitsConsumed, 2)
        XCTAssertEqual(sut.nextDose, now + 8 * 3600)
    }
    
    func test_prescriptionFinished() {
        // Given
        for _ in 1...9 {
            sut.takeDose()
            XCTAssertEqual(sut.getState(), .ongoing)
        }
        // When
        sut.takeDose()
        // Then
        XCTAssertEqual(sut.getState(), .finished)
        XCTAssertEqual(sut.unitsConsumed, 20)
    }

    func test_title() {
        XCTAssertEqual(sut.title(), "asdfg [0/20]")
    }

}
