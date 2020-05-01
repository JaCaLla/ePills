//
//  HomePrescriptionVMTest.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 30/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class HomePrescriptionVMTest: XCTestCase {

    var sut: HomePrescriptionVM!
    var homeCoordintorMock: HomeCoordinatorMock!
    var dataManager: DataManagerProtocol!
    var prescriptionInteractor: PrescriptionInteractor!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DataManager.shared.reset()
        dataManager = DataManager.shared
        prescriptionInteractor = PrescriptionInteractor(dataManager: dataManager)
        homeCoordintorMock = HomeCoordinatorMock()
        sut = HomePrescriptionVM(interactor: prescriptionInteractor,
                                 homeCoordinator: homeCoordintorMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_getPrescriptionsWhenAdded() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)

        let expecteds: [[Prescription]] = [
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(hours: 8, label: "8 hours"),
                          unitsDose: 1)]]
        var expetedsIdx = 0
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(hours: 8, label: "8 hours"),
                                        unitsDose: 1)
        // When
        prescriptionInteractor.add(prescription: prescription)

        sut.$prescriptions
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)

        sut.$currentPage
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(0, someValue)
            }).store(in: &cancellables)
        wait(for: [expectation], timeout: 0.1)
    }

    func test_getPrescriptionsWhenAdded2Prescriptions() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)

        let expecteds: [[Prescription]] = [[],
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(hours: 8, label: "8 hours"),
                          unitsDose: 1)], [
                Prescription(name: "a",
                             unitsBox: 10,
                             interval: Interval(hours: 8, label: "8 hours"),
                             unitsDose: 1),
                Prescription(name: "b",
                             unitsBox: 10,
                             interval: Interval(hours: 8, label: "8 hours"),
                             unitsDose: 1)
            ]]

        var expetedsIdx = 0
        let prescription1 = Prescription(name: "a",
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
                // Then
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }
                
            }
        ).store(in: &cancellables)
        // When
        prescriptionInteractor.add(prescription: prescription1)
        prescriptionInteractor.add(prescription: prescription2)

//        let expectedsCurrent: [Int] = [0,1]
//        var expectedsCurrentIdx = 0
//
//        sut.$currentPage
//            .sink(receiveCompletion: { completion in
//                XCTFail(".sink() received the completion:")
//            }, receiveValue: { someValue in
//                // Then
//                guard expectedsCurrentIdx < expectedsCurrent.count else { return }
//                XCTAssertEqual(expectedsCurrent[expectedsCurrentIdx], someValue)
//                expectedsCurrentIdx += 1
//                if expectedsCurrentIdx >= expectedsCurrent.count,
//                    expetedsIdx >= expecteds.count {
//                    expectation.fulfill()
//                }
//            }).store(in: &cancellables)
        wait(for: [expectation], timeout: 100.1)
    }

    func test_getCurrentPrescriptionsWhenAdded2Prescriptions() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)

        let expecteds: [Int] = [0, 0, 1]

        var expetedsIdx = 0
        let prescription1 = Prescription(name: "a",
                                         unitsBox: 10,
                                         interval: Interval(hours: 8, label: "8 hours"),
                                         unitsDose: 1)
        let prescription2 = Prescription(name: "b",
                                         unitsBox: 10,
                                         interval: Interval(hours: 8, label: "8 hours"),
                                         unitsDose: 1)

        sut.$currentPage
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }
            }).store(in: &cancellables)
        // When
        prescriptionInteractor.add(prescription: prescription1)
        prescriptionInteractor.add(prescription: prescription2)

        wait(for: [expectation], timeout: 0.1)
    }

    func test_addPrescription() throws {
        sut.addPrescription()
        XCTAssertEqual(homeCoordintorMock.presentPrescriptionFormCount, 1)
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
