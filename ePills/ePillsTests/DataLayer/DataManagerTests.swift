//
//  DataManagerTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class DataManagerTests: XCTestCase {

    var sut: DataManager = DataManager()

    override func setUpWithError() throws {
        sut.reset()
    }

    func test_reset() throws {
        // Given
        XCTAssertEqual(sut.getPrescriptions().count, 0)
        let prescription = Prescription(name: "a",
                                        unitsBox: "10",
                                        selectedIntervalIndex: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: "1")
        // When
        sut.add(prescription: prescription)
        // When
        sut.reset()
        // Then
        XCTAssertEqual(sut.getPrescriptions().count, 0)
    }

    func test_getPrescriptions() throws {


        // Given
        let prescription = Prescription(name: "a",
                                        unitsBox: "10",
                                        selectedIntervalIndex: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: "1")
        // When
        sut.add(prescription: prescription)
        // Test
        XCTAssertEqual(sut.getPrescriptions(), [Prescription(name: "a",
                                                             unitsBox: "10",
                                                             selectedIntervalIndex: Interval(hours: 8, label: "8 hours"),
                                                             unitsDose: "1")])

    }

    func test_addPrescriptions() throws {
        // Given
        let prescription = Prescription(name: "a",
                                        unitsBox: "10",
                                        selectedIntervalIndex: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: "1")
        // When
        sut.add(prescription: prescription)
        // Then
        XCTAssertEqual(sut.getPrescriptions().count, 1)

    }
}
