//
//  PrescriptionInteractorTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class PrescriptionInteractorTests: XCTestCase {

    var sut: PrescriptionInteractor!
    var dataManagerMock: DataManagerMock = DataManagerMock()
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        DataManager.shared.reset()
        sut = PrescriptionInteractor(dataManager: self.dataManagerMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addPrescriptionWhenDataManagerMock() throws {
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.add(prescription: prescription)
        XCTAssertEqual(dataManagerMock.addCount, 1)
    }

    func test_addPrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Prescription]] = [[],
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(hours: 8, label: "8 hours"),
                          unitsDose: 1)]]
        var expetedsIdx = 0

        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.$prescriptions
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When
        sut.add(prescription: prescription)
        wait(for: [expectation], timeout: 0.1)
    }

    func test_removePrescriptionWhenDataManagerMock() throws {
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.remove(prescription: prescription)
        XCTAssertEqual(dataManagerMock.removeCount, 1)
    }

    func test_removePrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Prescription]] = [[],
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(hours: 8, label: "8 hours"),
                          unitsDose: 1)],
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(hours: 8, label: "8 hours"),
                          unitsDose: 1)],
            []]
        var expetedsIdx = 0

        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        let prescription2 = Prescription(name: "b",
                                         unitsBox: 10,
                                         interval: Interval(hours: 8, label: "8 hours"),
                                         unitsDose: 1)
        sut.$prescriptions
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in

                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When
        sut.add(prescription: prescription)
        sut.remove(prescription: prescription2)
        sut.remove(prescription: prescription)
        wait(for: [expectation], timeout: 0.1)
    }
}
