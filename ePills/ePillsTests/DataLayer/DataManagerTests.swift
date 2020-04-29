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
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
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
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        // When
        sut.add(prescription: prescription)
        // Test
        XCTAssertEqual(sut.getPrescriptions(), [Prescription(name: "a",
                                                             unitsBox: 10,
                                                             interval: Interval(hours: 8, label: "8 hours"),
                                                             unitsDose: 1)])

    }

    func test_addPrescriptions() throws {
        // Given
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        // When
        sut.add(prescription: prescription)
        // Then
        XCTAssertEqual(sut.getPrescriptions().count, 1)

    }

    func test_getPresciptionsWhenManyNotStarted() {
        // Given
        var notStarted1 = Prescription(name: "notStarted3",
                                       unitsBox: 10,
                                       interval: Interval(hours: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted1.creation = 3
        var notStarted2 = Prescription(name: "notStarted1",
                                    unitsBox: 10,
                                    interval: Interval(hours: 8, label: "8 hours"),
                                    unitsDose: 1)
        notStarted2.creation = 1
        var notStarted3 = Prescription(name: "notStarted2",
                                     unitsBox: 10,
                                     interval: Interval(hours: 8, label: "8 hours"),
                                     unitsDose: 1)
        notStarted3.creation = 2
        DataManager.shared.add(prescription: notStarted3)
        DataManager.shared.add(prescription: notStarted1)
        DataManager.shared.add(prescription: notStarted2)
        
        // When
        let prescriptions = DataManager.shared.getPrescriptions()
        // Then
        guard prescriptions.count == 3 else {
            XCTFail()
            return
        }
        XCTAssertEqual(prescriptions[0].creation, 1)
        XCTAssertEqual(prescriptions[0].name, "notStarted1")
        XCTAssertEqual(prescriptions[1].creation, 2)
        XCTAssertEqual(prescriptions[1].name, "notStarted2")
        XCTAssertEqual(prescriptions[2].creation, 3)
        XCTAssertEqual(prescriptions[2].name, "notStarted3")

    }
}
