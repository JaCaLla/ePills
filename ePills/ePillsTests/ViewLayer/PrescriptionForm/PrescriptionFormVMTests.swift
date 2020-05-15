//
//  PrescriptionFormVMTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

@testable import ePills
import XCTest
import Combine

class PrescriptionFormVMTests: XCTestCase {

    var sut: PrescriptionFormVM!
    var prescriptionInteractorMock: PrescriptionInteractorMock!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        DataManager.shared.reset()
        prescriptionInteractorMock = PrescriptionInteractorMock()
        self.sut = PrescriptionFormVM(interactor: prescriptionInteractorMock, medicine: nil)
        Bundle.setLanguage(lang: "en")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addPrescriptionWhenMock() throws {
        // let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        sut = PrescriptionFormVM(interactor: prescriptionInteractorMock, medicine: nil)
        sut.save()
        XCTAssertEqual(prescriptionInteractorMock.addCount, 1)
    }

    func test_addPrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)

        let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        sut = PrescriptionFormVM(interactor: interactor, medicine: nil)
        sut.name = "a"
        sut.unitsBox = "10"
        sut.selectedIntervalIndex = Interval(secs: 8, label: "8 hours")
        sut.unitsDose = "1"

        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                          unitsBox: 10,
                          intervalSecs: 8,
                          unitsDose: 1)]]
        var expetedsIdx = 0

        interactor.getMedicines()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { medicines in
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], medicines)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When
        sut.save()
        
        // Then
        XCTAssertEqual(sut.title(), "Prescription form")
        wait(for: [expectation], timeout: 0.1)
    }

    func test_removePrescription() throws {
        let prescription = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut.remove(medicine: prescription)
        XCTAssertEqual(prescriptionInteractorMock.removeCount, 1)
    }
    
    func test_updatePrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)

        let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        let medicine = Medicine(name: "a",
        unitsBox: 10,
        intervalSecs: 8,
        unitsDose: 1)
        interactor.add(medicine: medicine)
        sut = PrescriptionFormVM(interactor: interactor, medicine: medicine)
        sut.name = "a"
        sut.unitsBox = "10"
        sut.selectedIntervalIndex = Interval(secs: 8, label: "8 hours")
        sut.unitsDose = "1"

        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                          unitsBox: 10,
                          intervalSecs: 8,
                          unitsDose: 1)]]
        var expetedsIdx = 0

        interactor.getMedicines()
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
        sut.save()
        
        // Then
        XCTAssertEqual(sut.title(), "Update prescription")
        wait(for: [expectation], timeout: 100.1)
    }
    
    func test_updatePrescriptionWhenMock() throws {
        let medicine = Medicine(name: "a",
                                        unitsBox: 10,
                                        intervalSecs: 8,
                                        unitsDose: 1)
        sut = PrescriptionFormVM(interactor: prescriptionInteractorMock, medicine: medicine)
        sut.save()
        XCTAssertEqual(prescriptionInteractorMock.updateCount, 1)
    }


    
}
