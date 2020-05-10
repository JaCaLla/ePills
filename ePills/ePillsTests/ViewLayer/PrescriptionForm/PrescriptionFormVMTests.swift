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
        self.sut = PrescriptionFormVM(interactor: prescriptionInteractorMock, prescription: nil)
        Bundle.setLanguage(lang: "en")
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addPrescriptionWhenMock() throws {
        // let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        sut = PrescriptionFormVM(interactor: prescriptionInteractorMock, prescription: nil)
        sut.save()
        XCTAssertEqual(prescriptionInteractorMock.addCount, 1)
    }

    func test_addPrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)

        let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        sut = PrescriptionFormVM(interactor: interactor, prescription: nil)
        sut.name = "a"
        sut.unitsBox = "10"
        sut.selectedIntervalIndex = Interval(secs: 8, label: "8 hours")
        sut.unitsDose = "1"

        let expecteds: [[Prescription]] = [
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)]]
        var expetedsIdx = 0

        interactor.getPrescriptions()
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
        XCTAssertEqual(sut.title(), "Prescription form")
        wait(for: [expectation], timeout: 0.1)
    }

    func test_removePrescription() throws {
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut.remove(prescription: prescription)
        XCTAssertEqual(prescriptionInteractorMock.removeCount, 1)
    }
    
    func test_updatePrescriptionWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)

        let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        let prescription = Prescription(name: "a",
        unitsBox: 10,
        interval: Interval(secs: 8, label: "8 hours"),
        unitsDose: 1)
        interactor.add(prescription: prescription)
        sut = PrescriptionFormVM(interactor: interactor, prescription: prescription)
        sut.name = "a"
        sut.unitsBox = "10"
        sut.selectedIntervalIndex = Interval(secs: 8, label: "8 hours")
        sut.unitsDose = "1"

        let expecteds: [[Prescription]] = [
            [Prescription(name: "a",
                          unitsBox: 10,
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)]]
        var expetedsIdx = 0

        interactor.getPrescriptions()
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
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        sut = PrescriptionFormVM(interactor: prescriptionInteractorMock, prescription: prescription)
        sut.save()
        XCTAssertEqual(prescriptionInteractorMock.updateCount, 1)
    }


    func test_getIntervals_en() throws {
        // Update the language by swaping bundle
        Bundle.setLanguage(lang: "en")
        // When
        let intervals = sut.getIntervals()
        guard intervals.count == 9 else {
            XCTFail()
            return
        }
        XCTAssertEqual(intervals[0].secs, 30)
        XCTAssertEqual(intervals[0].label, "_30 Secs")
        XCTAssertEqual(intervals[1].secs, 3600)
        XCTAssertEqual(intervals[1].label, "1 Hour")
        XCTAssertEqual(intervals[2].secs, 7200)
        XCTAssertEqual(intervals[2].label, "2 Hours")
        XCTAssertEqual(intervals[3].secs, 14400)
        XCTAssertEqual(intervals[3].label, "4 Hours")
        XCTAssertEqual(intervals[4].secs, 21600)
        XCTAssertEqual(intervals[4].label, "6 Hours")
        XCTAssertEqual(intervals[5].secs, 28800)
        XCTAssertEqual(intervals[5].label, "8 Hours")
        XCTAssertEqual(intervals[6].secs, 43200)
        XCTAssertEqual(intervals[6].label, "12 Hours")
        XCTAssertEqual(intervals[7].secs, 86400)
        XCTAssertEqual(intervals[7].label, "1 Day")
        XCTAssertEqual(intervals[8].secs, 172800)
        XCTAssertEqual(intervals[8].label, "2 Days")
    }
}
