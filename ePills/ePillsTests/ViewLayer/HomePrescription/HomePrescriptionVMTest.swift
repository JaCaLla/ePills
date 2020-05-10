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
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)]]
        var expetedsIdx = 0
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
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
                          interval: Interval(secs: 8, label: "8 hours"),
                          unitsDose: 1)], [
                Prescription(name: "a",
                             unitsBox: 10,
                             interval: Interval(secs: 8, label: "8 hours"),
                             unitsDose: 1),
                Prescription(name: "b",
                             unitsBox: 10,
                             interval: Interval(secs: 8, label: "8 hours"),
                             unitsDose: 1)
            ]]

        var expetedsIdx = 0
        let prescription1 = Prescription(name: "a",
                                         unitsBox: 10,
                                         interval: Interval(secs: 8, label: "8 hours"),
                                         unitsDose: 1)
        let prescription2 = Prescription(name: "b",
                                         unitsBox: 10,
                                         interval: Interval(secs: 8, label: "8 hours"),
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

        wait(for: [expectation], timeout: 100.1)
    }

    func test_getCurrentPrescriptionsWhenAdded2Prescriptions() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)

        let expecteds: [Int] = [0, 0, 1]

        var expetedsIdx = 0
        let prescription1 = Prescription(name: "a",
                                         unitsBox: 10,
                                         interval: Interval(secs: 8, label: "8 hours"),
                                         unitsDose: 1)
        let prescription2 = Prescription(name: "b",
                                         unitsBox: 10,
                                         interval: Interval(secs: 8, label: "8 hours"),
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

    func test_title() {

        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        // When
        prescriptionInteractor.add(prescription: prescription)

        XCTAssertEqual(sut.title(), "a [0/10]")
    }

    func test_iconNameWhenNotStarted() {
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)

        XCTAssertEqual(sut.getIconName(/*prescription: prescription,*/ timeManager: TimeManager()), "stop")
        XCTAssertEqual(sut.getMessage(/*prescription: prescription,*/ timeManager: TimeManager()), "Not started. Press icon to start")
        XCTAssertTrue(sut.updatable())
    }

    func test_iconNameWhenFinished() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        prescription.interval = Interval(secs: 3600, label: "1 hour")
        prescription.unitsBox = 1
        prescription.unitsDose = 1
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getIconName(/*prescription: prescription,*/ timeManager: timeManager), "clear")
        XCTAssertEqual(sut.getMessage(/*prescription: prescription,*/ timeManager: TimeManager()), "Presciption finished, press renew to start again")
        XCTAssertTrue(sut.updatable())
    }

    func test_iconNameWhenOngoing() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8 * 3600, label: "8 hours"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        // When
        prescription.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.getIconName(/*prescription: prescription,*/ timeManager: timeManager), "play")
        XCTAssertEqual(sut.getMessage(/*prescription: prescription,*/ timeManager: TimeManager()), "Dose ellapsed, press icon to mark")
        XCTAssertFalse(sut.updatable())
    }

    func test_iconNameWhenOngoingReady() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        prescription.interval = Interval(secs: 10, label: "1 hour")
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
        // Then
        XCTAssertEqual(sut.getIconName(/*prescription: prescription,*/ timeManager: timeManager), "alarm")
        XCTAssertEqual(sut.getMessage(/*prescription: prescription,*/ timeManager: TimeManager()), "Dose ellapsed, press icon to mark")
        XCTAssertFalse(sut.updatable())
    }

    func test_iconNameWhenNotOngoingEllapsed() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        prescription.interval = Interval(secs: 10, label: "1 hour")
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
        XCTAssertEqual(sut.getIconName(/*prescription: prescription,*/ timeManager: timeManager), "exclamationmark.triangle")
        XCTAssertEqual(sut.getMessage(/*prescription: prescription,*/ timeManager: TimeManager()), "Dose ellapsed, press icon to mark")
        XCTAssertFalse(sut.updatable())
    }

    func test_getRemainingTimeMessageWhenNotOngoing() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 8, label: "8 hours"),
                                        unitsDose: 1)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")

        prescription.interval = Interval(secs: 1, label: "1 hour")

    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanAMonth() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 3600 * 24 * 32, label: "More than 1 month"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")

        prescription.nextDose = nil
        prescription.interval = Interval(secs: 3600 * 24 * 31, label: "More than 1 month")
        prescription.takeDose(timeManager: timeManager)
        prescriptionInteractor.add(prescription: prescription)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanDays() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 3600 * 24 * 1 + 3600, label: "1 day and 1 hour"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "-1d")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "01h")

        prescription.nextDose = nil
        prescription.interval = Interval(secs: 3600 * 24 * 1, label: "1 day")
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "-1d")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "00h")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanHours() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 3600 * 24 * 1 - 1, label: "23 h 59m 59s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "-23h")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "59m")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanMins() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 3600 * 1 - 1, label: " 59m 59s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "-59m")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "59s")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanSecs() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 30, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "-30s")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanSecs() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 30, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 45))
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "15s")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanMins() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 0, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 60 * 5 + 10))
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "05m")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "10s")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanHours() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 0, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 5 + 180))
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "05h")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "03m")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanDays() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 0, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 24 * 2 + 180))
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "02d")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "00h")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanMonths() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 0, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 24 * 60 + 180))
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanYears() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let prescription = Prescription(name: "a",
                                        unitsBox: 10,
                                        interval: Interval(secs: 0, label: " 30s"),
                                        unitsDose: 1)
        prescriptionInteractor.add(prescription: prescription)
        prescription.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 24 * 400))
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(/*prescription: prescription,*/ timeManager: timeManager).1, "")
    }
    
    
}
