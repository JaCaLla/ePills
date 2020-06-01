//
//  cycleInteractorTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest
import Combine

class cycleInteractorTests: XCTestCase {

    var sut: MedicineInteractor!
    var dataManagerMock: DataManagerMock = DataManagerMock()
    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        DataManager.shared.reset()
        sut = MedicineInteractor(dataManager: self.dataManagerMock)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_addcycleWhenDataManagerMock() throws {
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        sut.add(medicine: medicine, timeManager: TimeManager())
        XCTAssertEqual(dataManagerMock.addCount, 1)
    }

    func test_addcycleWhenDataManagerReal() throws {
        //  let expectation = XCTestExpectation(description: self.debugDescription)
        sut = MedicineInteractor(dataManager: DataManager.shared)

        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                      unitsBox: 10,
                      intervalSecs: 8,
                      unitsDose: 1)]]
        var expetedsIdx = 0

        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    //    expectation.fulfill()
                }

            }).store(in: &cancellables)
        // When
        sut.add(medicine: medicine, timeManager: TimeManager())
        //  wait(for: [expectation], timeout: 0.1)
    }

    func test_cycleDateRangesWhenCreated() {
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }
        let cycles = sut.getCycleDatesStr(medicine: createdMedicine)
        guard cycles.count == 5 else { XCTFail(); return }
        XCTAssertEqual(cycles[0], "01/03/2020")
        XCTAssertEqual(cycles[1], "02/03/2020")
        XCTAssertEqual(cycles[2], "03/03/2020")
        XCTAssertEqual(cycles[3], "04/03/2020")
        XCTAssertEqual(cycles[4], "05/03/2020")
    }

    func test_cycleDateRangesAfterTakeDose() {
        //  let asyncExpectation = expectation(description: "\(#function)")
        var testFinished = false
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 48)) //3-March-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        let suscripiton = sut.getMedicinesPublisher()

        suscripiton.sink(receiveCompletion: { completion in
            XCTFail(".sink() received the completion:")
        }, receiveValue: { someValue in
            guard let medicine = someValue.first, !testFinished else { return }
            let cycles = self.sut.getCycleDatesStr(medicine: medicine)
            guard cycles.count == 5 else { return }
            XCTAssertEqual(cycles[0], "03/03/2020")
            XCTAssertEqual(cycles[1], "04/03/2020")
            XCTAssertEqual(cycles[2], "05/03/2020")
            XCTAssertEqual(cycles[3], "06/03/2020")
            XCTAssertEqual(cycles[4], "07/03/2020")
            testFinished = true

            //  asyncExpectation.fulfill()
        }).store(in: &cancellables)
        sut.flushMedicines()

        // self.waitForExpectations(timeout: 2.0, handler: nil)
    }

    func test_cycleDateRangesAfterTwoTakeDose() {
        // let asyncExpectation = expectation(description: "\(#function)")
        var testFinished = false
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else { XCTFail(); return }
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 48)) //3-March-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard let medicine = someValue.first, !testFinished else { return }
                let cycles = self.sut.getCycleDatesStr(medicine: medicine)
                guard cycles.count == 5 else { XCTFail(); return }
                XCTAssertEqual(cycles[0], "03/03/2020")
                XCTAssertEqual(cycles[1], "04/03/2020")
                XCTAssertEqual(cycles[2], "05/03/2020")
                XCTAssertEqual(cycles[3], "06/03/2020")
                XCTAssertEqual(cycles[4], "07/03/2020")
                testFinished = true
                // asyncExpectation.fulfill()
            }).store(in: &cancellables)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 72)) //4-March-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)

        //  self.waitForExpectations(timeout: 2.0, handler: nil)
    }

    func test_removecycleWhenDataManagerMock() throws {
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        sut.remove(medicine: medicine)
        XCTAssertEqual(dataManagerMock.removeCount, 1)
    }

    func test_removecycleWhenDataManagerReal() throws {
        let expectation = XCTestExpectation(description: self.debugDescription)
        sut = MedicineInteractor(dataManager: DataManager.shared)


        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                      unitsBox: 10,
                      intervalSecs: 8,
                      unitsDose: 1)],
            [Medicine(name: "a",
                      unitsBox: 10,
                      intervalSecs: 8,
                      unitsDose: 1)],
            []]
        var expetedsIdx = 0

        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        let medicine2 = Medicine(name: "b",
                                 unitsBox: 10,
                                 intervalSecs: 8,
                                 unitsDose: 1)


        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else { /*XCTFail();*/ expectation.fulfill(); return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
                if expetedsIdx >= expecteds.count {
                    expectation.fulfill()
                }
            }).store(in: &cancellables)
        // When
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: TimeManager()) else { XCTFail(); return }
        sut.remove(medicine: medicine2)
        sut.remove(medicine: createdMedicine)
        wait(for: [expectation], timeout: 1.0)
    }

    func test_updatecycleWhenDataManagerMock() throws {
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        sut.update(medicine: medicine)
        XCTAssertEqual(dataManagerMock.updateCount, 1)
    }

    func test_updatecycleWhenDataManagerReal() throws {
        //   let asyncExpectation = expectation(description: "\(#function)")

        sut = MedicineInteractor(dataManager: DataManager.shared)

        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)

        let expecteds: [[Medicine]] = [
            [Medicine(name: "nameUpdated",
                      unitsBox: 20,
                      intervalSecs: 2,
                      unitsDose: 2)]]
        var expetedsIdx = 0

        guard let createdMedicine = sut.add(medicine: medicine, timeManager: TimeManager()) else { XCTFail(); return }

        sut.getMedicinesPublisher()
            .sink(receiveCompletion: { completion in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard let medicine = someValue.first else { XCTFail();return }
                XCTAssertEqual(medicine.name, "nameUpdated")
                XCTAssertEqual(medicine.unitsBox, 20)
                XCTAssertEqual(medicine.intervalSecs, 2)
                XCTAssertEqual(medicine.unitsDose, 2)
//                asyncExpectation.fulfill()

            }).store(in: &cancellables)
        // When
        createdMedicine.name = "nameUpdated"
        createdMedicine.unitsBox = 20
        createdMedicine.intervalSecs = 2
        createdMedicine.unitsDose = 2
        sut.update(medicine: createdMedicine)

        //    self.waitForExpectations(timeout: 2.0, handler: nil)
    }

    func test_getExpirationDayNumberWhen1() {
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail();
            return }

        XCTAssertEqual(sut.getExpirationDayNumber(medicine: createdMedicine), "5")

    }

    func test_getExpirationDayNumberWhen29() {
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400)) //29-Feb-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 1,
                                intervalSecs: 3600 * 1,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail();
            return }

        XCTAssertEqual(sut.getExpirationDayNumber(medicine: createdMedicine), "29")

    }

    func test_getExpirationMonthYear() {
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400)) //29-Feb-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 1,
                                intervalSecs: 3600 * 1,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail();
            return }

        XCTAssertEqual(sut.getExpirationMonthYear(medicine: createdMedicine), "Febrero - 2020")
    }
    
    func test_getExpirationWeekdayHourMinute() {
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400)) //29-Feb-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 1,
                                intervalSecs: 3600 * 1,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail();
            return }

        XCTAssertEqual(sut.getExpirationWeekdayHourMinute(medicine: createdMedicine), "Sábado - 02:00")
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
