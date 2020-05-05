//
//  DataManagerTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class DataManagerTests: XCTestCase {

    var sut: DataManager = DataManager()
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        sut.reset()
    }

    func test_reset() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)
// Given
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.add(prescription: prescription)
        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                XCTAssertEqual(someValue, [])
                expectation.fulfill()
            }).store(in: &cancellables)


        // When
        sut.reset()

        wait(for: [expectation], timeout: 1.0)
    }

    func test_getPrescriptions() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)

        // Given
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)

        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(someValue, [Prescription(name: "a",
                                                        unitsBox: 10,
                                                        interval: Interval(secs: 8, label: "8 hours"),
                                                        unitsDose: 1)])
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.add(prescription: prescription)
        wait(for: [expectation], timeout: 0.1)

    }

    func test_addPrescriptions() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        let prescription1 = Prescription(name: "a",
                                         unitsBox: 10,
                                         interval: Interval(secs: 8, label: "8 hours"),
                                         unitsDose: 1)

        sut.add(prescription: prescription1)

        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(someValue, [Prescription(name: "a",
                                                        unitsBox: 10,
                                                        interval: Interval(secs: 8, label: "8 hours"),
                                                        unitsDose: 1),
                                   Prescription(name: "b",
                                                unitsBox: 5,
                                                interval: Interval(secs: 4, label: "4 hours"),
                                                unitsDose: 2)
                ])
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        let prescription2 = Prescription(name: "b",
                                         unitsBox: 5,
                                         interval: Interval(secs: 4, label: "4 hours"),
                                         unitsDose: 2)
        sut.add(prescription: prescription2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_getPresciptionsWhenManyNotStarted() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        var notStarted1 = Prescription(name: "notStarted3",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted1.creation = 3
        var notStarted2 = Prescription(name: "notStarted1",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted2.creation = 1
        var notStarted3 = Prescription(name: "notStarted2",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted3.creation = 2
        sut.add(prescription: notStarted3)
        sut.add(prescription: notStarted1)

        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 3 else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(prescriptions[0].creation, 1)
                XCTAssertEqual(prescriptions[0].name, "notStarted1")
                XCTAssertEqual(prescriptions[0].getState(), .notStarted)
                XCTAssertEqual(prescriptions[1].creation, 2)
                XCTAssertEqual(prescriptions[1].name, "notStarted2")
                XCTAssertEqual(prescriptions[1].getState(), .notStarted)
                XCTAssertEqual(prescriptions[2].creation, 3)
                XCTAssertEqual(prescriptions[2].name, "notStarted3")
                XCTAssertEqual(prescriptions[2].getState(), .notStarted)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.add(prescription: notStarted2)

        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_removePrescriptions() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        var notStarted1 = Prescription(name: "notStarted1",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted1.creation = 1
        var notStarted2 = Prescription(name: "notStarted2",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted2.creation = 2
        var notStarted3 = Prescription(name: "notStarted3",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted3.creation = 3
        sut.add(prescription: notStarted3)
        sut.add(prescription: notStarted1)
        sut.add(prescription: notStarted2)
        
        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 2 else {
                    XCTFail()
                    return
                }
                XCTAssertEqual(prescriptions[0].creation, 1)
                XCTAssertEqual(prescriptions[0].name, "notStarted1")
                XCTAssertEqual(prescriptions[0].getState(), .notStarted)
                XCTAssertEqual(prescriptions[1].creation, 3)
                XCTAssertEqual(prescriptions[1].name, "notStarted3")
                XCTAssertEqual(prescriptions[1].getState(), .notStarted)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.remove(prescription: notStarted2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_updatePrescriptions() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        let notStarted1 = Prescription(name: "notStarted1",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted1.creation = 1
        var notStarted2 = Prescription(name: "notStarted2",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted2.name = "aaa"
        notStarted2.unitsBox = 0
        notStarted2.interval = Interval(secs: 11, label: "aa")
        notStarted2.unitsDose = 0
        notStarted2.unitsConsumed = 0
        notStarted2.nextDose = nil
        notStarted2.creation = 2
        let notStarted3 = Prescription(name: "notStarted3",
                                       unitsBox: 10,
                                       interval: Interval(secs: 8, label: "8 hours"),
                                       unitsDose: 1)
        notStarted3.creation = 3
        sut.add(prescription: notStarted3)
        sut.add(prescription: notStarted1)
        sut.add(prescription: notStarted2)
        
        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 3 else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(prescriptions[1].name, "bbb")
                XCTAssertEqual(prescriptions[1].unitsBox, 1)
                XCTAssertEqual(prescriptions[1].interval, Interval(secs: 12, label: "bb"))
                XCTAssertEqual(prescriptions[1].unitsDose, 1)
                XCTAssertEqual(prescriptions[1].unitsConsumed, 1)
                XCTAssertEqual(prescriptions[1].nextDose, 1)
                XCTAssertEqual(prescriptions[1].creation, 2)
                XCTAssertEqual(prescriptions[1].getState(), .finished)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        notStarted2.name = "bbb"
        notStarted2.unitsBox = 1
        notStarted2.interval = Interval(secs: 12, label: "bb")
        notStarted2.unitsDose = 1
        notStarted2.unitsConsumed = 1
        notStarted2.nextDose = 1
        notStarted2.creation = 2
        sut.update(prescription: notStarted2)

        wait(for: [expectation], timeout: 100.1)
    }

}
