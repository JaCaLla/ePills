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
