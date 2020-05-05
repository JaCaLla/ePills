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
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.add(prescription: prescription)
        XCTAssertEqual(dataManagerMock.addCount, 1)
    }

    func test_addPrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Prescription]] = [
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)]]
        var expetedsIdx = 0

        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.getPrescriptions()
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
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.remove(prescription: prescription)
        XCTAssertEqual(dataManagerMock.removeCount, 1)
    }

    func test_removePrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let expecteds: [[Prescription]] = [
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)],
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)],
            []]
        var expetedsIdx = 0

        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        let prescription2 = Prescription(name: "b",
                                         unitsBox: 10,
                                         interval: Interval(secs: 8, label: "8 hours"),
                                         unitsDose: 1)
        sut.getPrescriptions()
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
        sut.remove(prescription: prescription2)
        sut.remove(prescription: prescription)
        wait(for: [expectation], timeout: 0.1)
    }

    func test_takeDosePrescriptionWhenDataManagerMock() throws {
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.takeDose(prescription: prescription, timeManager: TimeManager())
        XCTAssertEqual(dataManagerMock.updateCount, 1)
    }

    func test_takeDosePrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = PrescriptionInteractor(dataManager: DataManager.shared)

        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 10, label: "10 secs"),
                                        unitsDose: 1)
        sut.add(prescription: prescription)
        XCTAssertEqual(prescription.getState(), .notStarted)
        var takeIdx = 0
        sut.getPrescriptions()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard let prescription = someValue.first else {
                    XCTFail()
                    expectation.fulfill()
                    return
                }
                // Then
                if takeIdx < 9 {
                    print("\(takeIdx) \(prescription.getState())")
                    XCTAssertEqual(prescription.getState(timeManager: timeManager), .ongoing)
                    XCTAssertEqual(prescription.unitsConsumed, takeIdx + 1)
                    XCTAssertEqual(prescription.nextDose, (takeIdx + 1) * 10)
                } else {
                    XCTAssertEqual(prescription.getState(timeManager: timeManager), .finished)
                    XCTAssertEqual(prescription.unitsConsumed, 10)
                    XCTAssertNil(prescription.nextDose)
                }
                takeIdx += 1
                if takeIdx >= 1 {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When

        
        for idx in 1...10 {
            sut.takeDose(prescription: prescription, timeManager: timeManager)
            timeManager.setInjectedDate(date: Date(timeIntervalSince1970: TimeInterval(idx * 10)))
        }
         sut.takeDose(prescription: prescription, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 90))
        //
        wait(for: [expectation], timeout: 100.1)
    }
}
