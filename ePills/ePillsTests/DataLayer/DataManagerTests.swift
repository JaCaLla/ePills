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
        let medicine = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut.add(medicine: medicine)
        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                 expectation.fulfill()
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
        let prescription = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)

        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                 expectation.fulfill()
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(someValue, [Medicine(name: "a",
                                                        unitsBox: 10,
                                                        intervalSecs: 8,
                                                        unitsDose: 1)])
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.add(medicine: prescription)
        wait(for: [expectation], timeout: 0.1)

    }

    func test_addPrescriptions() throws {
        // Given
        let expectation = XCTestExpectation(description: self.debugDescription)
        let prescription1 = Medicine(name: "a",
                                         unitsBox: 10,
                                         intervalSecs: 8,
                                         unitsDose: 1)

        sut.add(medicine: prescription1)

        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
                 expectation.fulfill()
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(someValue, [Medicine(name: "a",
                                                        unitsBox: 10,
                                                        intervalSecs: 8,
                                                        unitsDose: 1),
                                   Medicine(name: "b",
                                                unitsBox: 5,
                                                intervalSecs: 4,
                                                unitsDose: 2)
                ])
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        let prescription2 = Medicine(name: "b",
                                         unitsBox: 5,
                                         intervalSecs: 4,
                                         unitsDose: 2)
        sut.add(medicine: prescription2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_getPresciptionsWhenManyNotStarted() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        var notStarted1 = Medicine(name: "notStarted3",
                                       unitsBox: 10,
                                       intervalSecs: 4,
                                       unitsDose: 1)
        notStarted1.currentCycle.creation = 3
        var notStarted2 = Medicine(name: "notStarted1",
                                       unitsBox: 10,
                                       intervalSecs: 4,
                                       unitsDose: 1)
        notStarted2.currentCycle.creation = 1
        var notStarted3 = Medicine(name: "notStarted2",
                                       unitsBox: 10,
                                       intervalSecs: 8,
                                       unitsDose: 1)
        notStarted3.currentCycle.creation = 2
        sut.add(medicine: notStarted3)
        sut.add(medicine: notStarted1)

        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 3 else {
                    XCTFail()
                     expectation.fulfill()
                    return
                }
                XCTAssertEqual(prescriptions[0].currentCycle.creation, 1)
                XCTAssertEqual(prescriptions[0].name, "notStarted1")
                XCTAssertEqual(prescriptions[0].getState(), .notStarted)
                XCTAssertEqual(prescriptions[1].currentCycle.creation, 2)
                XCTAssertEqual(prescriptions[1].name, "notStarted2")
                XCTAssertEqual(prescriptions[1].getState(), .notStarted)
                XCTAssertEqual(prescriptions[2].currentCycle.creation, 3)
                XCTAssertEqual(prescriptions[2].name, "notStarted3")
                XCTAssertEqual(prescriptions[2].getState(), .notStarted)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.add(medicine: notStarted2)

        wait(for: [expectation], timeout: 0.1)
    }
    
    func test_removePrescriptions() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
        var notStarted1 = Medicine(name: "notStarted1",
                                       unitsBox: 10,
                                       intervalSecs: 8,
                                       unitsDose: 1)
        notStarted1.currentCycle.creation = 1
        var notStarted2 = Medicine(name: "notStarted2",
                                       unitsBox: 10,
                                       intervalSecs: 8,
                                       unitsDose: 1)
        notStarted2.currentCycle.creation = 2
        var notStarted3 = Medicine(name: "notStarted3",
                                       unitsBox: 10,
                                       intervalSecs: 8,
                                       unitsDose: 1)
        notStarted3.currentCycle.creation = 3
        sut.add(medicine: notStarted3)
        sut.add(medicine: notStarted1)
        sut.add(medicine: notStarted2)
        
        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 2 else {
                    XCTFail()
                     expectation.fulfill()
                    return
                }
                XCTAssertEqual(prescriptions[0].currentCycle.creation, 1)
                XCTAssertEqual(prescriptions[0].name, "notStarted1")
                XCTAssertEqual(prescriptions[0].getState(), .notStarted)
                XCTAssertEqual(prescriptions[1].currentCycle.creation, 3)
                XCTAssertEqual(prescriptions[1].name, "notStarted3")
                XCTAssertEqual(prescriptions[1].getState(), .notStarted)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        sut.remove(medicine: notStarted2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_updatePrescriptions() {
        let expectation = XCTestExpectation(description: self.debugDescription)
        // Given
//        let notStarted1 = Medicine(name: "notStarted1",
//                                       unitsBox: 10,
//                                       intervalSecs: 8,
//                                       unitsDose: 1)
//        notStarted1.creation = 1
        var notStarted2 = Medicine(name: "notStarted2",
                                       unitsBox: 10,
                                       intervalSecs: 8,
                                       unitsDose: 1)
        notStarted2.name = "aaa"
        notStarted2.unitsBox = 0
        notStarted2.intervalSecs = 11
        notStarted2.unitsDose = 0
        notStarted2.currentCycle.unitsConsumed = 1
        notStarted2.currentCycle.nextDose = nil
        notStarted2.currentCycle.creation = 2
//        let notStarted3 = Medicine(name: "notStarted3",
//                                       unitsBox: 10,
//                                       intervalSecs: 8,
//                                       unitsDose: 1)
 //       notStarted3.creation = 3
//        sut.add(medicine: notStarted3)
//        sut.add(medicine: notStarted1)
        sut.add(medicine: notStarted2)
        
        sut.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { prescriptions in
                // Then
                guard prescriptions.count == 1 else {
                    XCTFail()
                    return
                }
                
                XCTAssertEqual(prescriptions[0].name, "bbb")
                XCTAssertEqual(prescriptions[0].unitsBox, 1)
                XCTAssertEqual(prescriptions[0].intervalSecs, 12)
                XCTAssertEqual(prescriptions[0].unitsDose, 1)
                XCTAssertEqual(prescriptions[0].currentCycle.unitsConsumed, 1)
                XCTAssertEqual(prescriptions[0].currentCycle.nextDose,1)
                XCTAssertEqual(prescriptions[0].currentCycle.creation, 2)
                XCTAssertEqual(prescriptions[0].getState(), .ongoingEllapsed)
                expectation.fulfill()
            }).store(in: &cancellables)
        // When
        notStarted2.name = "bbb"
        notStarted2.unitsBox = 1
        notStarted2.intervalSecs = 12
        notStarted2.unitsDose = 1
        notStarted2.currentCycle.unitsConsumed = 1
        notStarted2.currentCycle.nextDose = 1
        notStarted2.currentCycle.creation = 2
        sut.update(medicine: notStarted2)

        wait(for: [expectation], timeout: 100.1)
    }


}
