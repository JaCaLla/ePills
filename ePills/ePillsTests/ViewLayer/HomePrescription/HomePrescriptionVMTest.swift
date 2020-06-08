//
//  HomecycleVMTest.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 30/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class HomePrescriptionVMTests: XCTestCase {

    var sut: HomePrescriptionVM!
    var homeCoordintorMock: HomeCoordinatorMock!
    var dataManager: DataManagerProtocol!
    var prescriptionInteractor: MedicineInteractor!
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        DataManager.shared.reset()
        dataManager = DataManager.shared
        prescriptionInteractor = MedicineInteractor(dataManager: dataManager)
        homeCoordintorMock = HomeCoordinatorMock()
        sut = HomePrescriptionVM(interactor: prescriptionInteractor,
                                 homeCoordinator: homeCoordintorMock)
    }

    func test_getcyclesWhenAdded() throws {
        var testFinished = false
        let expecteds: [[Medicine]] = [[],
                                       [Medicine(name: "a",
                                                 unitsBox: 10,
                                                 intervalSecs: 8,
                                                 unitsDose: 1)]]
        var expetedsIdx = 0
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        // When
        sut.$medicines
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { medicines in
                // Then
                guard !testFinished else { return }
                guard expetedsIdx < expecteds.count else { return }
                if expetedsIdx == 0 {
                    XCTAssertEqual(medicines.count, 0)
                } else if expetedsIdx == 1 {
                    XCTAssertEqual(medicines.count, 1)
                    XCTAssertEqual(expecteds[expetedsIdx], medicines)
                } else {
                    testFinished = true
                }
                expetedsIdx += 1
            })
            .store(in: &cancellables)

        sut.$currentPage
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                XCTAssertEqual(0, someValue)
            })
            .store(in: &cancellables)

        _ = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager())
    }

    func test_getcyclesWhenAdded2cycles() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)

        let expecteds: [[Medicine]] = [[],
                                       [Medicine(name: "a",
                                                 unitsBox: 10,
                                                 intervalSecs: 8,
                                                 unitsDose: 1)],
                                       [Medicine(name: "a",
                                                 unitsBox: 10,
                                                 intervalSecs: 8,
                                                 unitsDose: 1),
                                        Medicine(name: "b",
                                                 unitsBox: 10,
                                                 intervalSecs: 8,
                                                 unitsDose: 1)
                                       ]]
        var expetedsIdx = 0
        let cycle = Medicine(name: "a",
                             unitsBox: 10,
                             intervalSecs: 8,
                             unitsDose: 1)
        let cycle2 = Medicine(name: "b",
                              unitsBox: 10,
                              intervalSecs: 8,
                              unitsDose: 1)
        // When
        sut
            .$medicines
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }

            })
            .store(in: &cancellables)

        _ = prescriptionInteractor.add(medicine: cycle, timeManager: TimeManager())
        _ = prescriptionInteractor.add(medicine: cycle2, timeManager: TimeManager())

        wait(for: [expectation], timeout: 10)
    }

    func test_getCurrentcyclesWhenAdded2cycles() throws {

        let expectation = XCTestExpectation(description: self.debugDescription)

        let expecteds: [Int] = [0, 0, 1]

        var expetedsIdx = 0
        let cycle1 = Medicine(name: "a",
                              unitsBox: 10,
                              intervalSecs: 8,
                              unitsDose: 1)
        let cycle2 = Medicine(name: "b",
                              unitsBox: 10,
                              intervalSecs: 8,
                              unitsDose: 1)

        sut
            .$currentPage
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                // Then
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }
            })
            .store(in: &cancellables)
        // When
        _ = prescriptionInteractor.add(medicine: cycle1, timeManager: TimeManager())
        _ = prescriptionInteractor.add(medicine: cycle2, timeManager: TimeManager())

        wait(for: [expectation], timeout: 0.1)
    }

    func test_addPrescription() throws {
        sut.addPrescription()
        XCTAssertEqual(homeCoordintorMock.presentPrescriptionFormCount, 1)
    }

    func test_title() {

        let cycle = Medicine(name: "a",
                             unitsBox: 10,
                             intervalSecs: 8,
                             unitsDose: 1)
        // When
        _ = prescriptionInteractor.add(medicine: cycle, timeManager: TimeManager())

        XCTAssertEqual(sut.title(), "a [0/10]")
    }

    func test_iconNameWhenNotStarted() {
        let cycle = Medicine(name: "a",
                             unitsBox: 10,
                             intervalSecs: 8,
                             unitsDose: 1)
        _ = prescriptionInteractor.add(medicine: cycle, timeManager: TimeManager())

        XCTAssertEqual(sut.getIconName(timeManager: TimeManager()), "cursor.rays")
        XCTAssertEqual(sut.getMessage(timeManager: TimeManager()), "Not started.\nPress icon to start")
        XCTAssertTrue(sut.updatable())
        XCTAssertEqual(sut.getPrescriptionTime(timeManager: TimeManager()), "")
        XCTAssertEqual(sut.getCurrentDoseProgress(timeManager: TimeManager()), 0)
        XCTAssertEqual(sut.hasDoses(), false)
    }

    func test_iconNameWhenFinished() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        let medicine = Medicine(name: "a",
                                unitsBox: 1,
                                intervalSecs: 8,
                                unitsDose: 1)
        medicine.intervalSecs = 3600
        medicine.unitsBox = 1
        medicine.unitsDose = 1
        guard let created = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("test_iconNameWhenFinished")
            return
        }
        prescriptionInteractor.takeDose(medicine: created, timeManager: timeManager)
        XCTAssertEqual(sut.getIconName(timeManager: timeManager), "clear")
        XCTAssertEqual(sut.getMessage(timeManager: TimeManager()), "Presciption finished")
        XCTAssertTrue(sut.updatable())
        XCTAssertEqual(sut.getPrescriptionTime(timeManager: TimeManager()), "")
        XCTAssertEqual(sut.getCurrentDoseProgress(timeManager: TimeManager()), 0)
        XCTAssertEqual(sut.hasDoses(), true)
    }

    func test_iconNameWhenOngoing() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8 * 3600,
                                unitsDose: 1)

        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine,
                                                               timeManager: TimeManager()) else { return }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 8 * 3600 - 1000))
        // When
        // Then
        XCTAssertEqual(sut.getIconName(timeManager: timeManager), "moon.zzz")
        XCTAssertEqual(sut.getMessage(timeManager: timeManager), "In course,\nnext dose:")
        XCTAssertFalse(sut.updatable())
        XCTAssertEqual(sut.getPrescriptionTime(timeManager: TimeManager()), "09:00")
        XCTAssertEqual(sut.getCurrentDoseProgress(timeManager: TimeManager()), 1.0)
        XCTAssertEqual(sut.hasDoses(), true)
    }

    func test_iconNameWhenOngoingReady() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 10,
                                unitsDose: 1)
        medicine.intervalSecs = 10
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
        // Then
        XCTAssertEqual(sut.getIconName(timeManager: timeManager), "alarm")
        XCTAssertEqual(sut.getMessage(timeManager: TimeManager()), "Dose ellapsed,\npress icon to mark")
        XCTAssertFalse(sut.updatable())
        XCTAssertEqual(sut.getPrescriptionTime(timeManager: TimeManager()), "01:00")
        XCTAssertEqual(sut.getCurrentDoseProgress(timeManager: TimeManager()), 1.0)
        XCTAssertEqual(sut.hasDoses(), true)
    }

    func test_iconNameWhenNotOngoingEllapsed() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        medicine.intervalSecs = 10
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)

        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
        XCTAssertEqual(sut.getIconName(timeManager: timeManager), "exclamationmark.triangle")
        XCTAssertEqual(sut.getMessage(timeManager: TimeManager()), "Dose ellapsed,\npress icon to mark")
        XCTAssertFalse(sut.updatable())
        XCTAssertEqual(sut.getPrescriptionTime(timeManager: TimeManager()), "01:00")
        XCTAssertEqual(sut.getCurrentDoseProgress(timeManager: TimeManager()), 1.0)
        XCTAssertEqual(sut.hasDoses(), true)
    }

    func test_getRemainingTimeMessageWhenNotOngoing() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")
        XCTAssertEqual(sut.getCurrentDoseProgress(timeManager: TimeManager()), 0)
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanAMonth() {
        // Case 1
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 3600 * 24 * 32,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")

        createdMedicine.currentCycle.nextDose = nil
        createdMedicine.intervalSecs = 3600 * 24 * 31
        prescriptionInteractor.update(medicine: createdMedicine)
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)

        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanDays() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 3600 * 24 * 1 + 3600,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "-1d")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "01h")

        createdMedicine.currentCycle.nextDose = nil
        createdMedicine.intervalSecs = 3600 * 24 * 1
        prescriptionInteractor.update(medicine: createdMedicine)
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "-1d")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "00h")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanHours() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 3600 * 24 * 1 - 1,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "-23h")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "59m")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanMins() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 3600 * 1 - 1,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "-59m")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "59s")
    }

    func test_getRemainingTimeMessageWhenNextIsGreaterThanSecs() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 30,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "-30s")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanSecs() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 30,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 45))
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "15s")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanMins() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 0,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 60 * 5 + 10))
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "05m")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "10s")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanHours() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 0,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 5 + 180))
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "05h")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "03m")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanDays() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 0,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 24 * 2 + 180))
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "02d")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "00h")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanMonths() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 0,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 24 * 60 + 180))
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")
    }

    func test_getRemainingTimeMessageWhenNextEllapsedThanYears() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.timeManager = timeManager
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 0,
                                unitsDose: 1)
        guard let createdMedicine = prescriptionInteractor.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("Errror adding")
            return
        }
        prescriptionInteractor.takeDose(medicine: createdMedicine, timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600 * 24 * 400))
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).0, "> Month")
        XCTAssertEqual(sut.getRemainingTimeMessage(timeManager: timeManager).1, "")
    }
}
