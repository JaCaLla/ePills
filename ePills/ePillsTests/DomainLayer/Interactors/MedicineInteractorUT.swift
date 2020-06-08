//
//  cycleInteractorTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Combine
@testable import ePills
import XCTest

class MedicineInteractorUT: XCTestCase {

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
        _ = sut.add(medicine: medicine, timeManager: TimeManager())
        XCTAssertEqual(dataManagerMock.addCount, 1)
    }

    func test_addcycleWhenDataManagerReal() throws {
        sut = MedicineInteractor(dataManager: DataManager.shared)

        let expecteds: [[Medicine]] = [
            [Medicine(name: "a",
                      unitsBox: 10,
                      intervalSecs: 8,
                      unitsDose: 1)
            ]
        ]
        var expetedsIdx = 0
        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)
        let subscription = sut
            .getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else { return }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
            })
        subscription.store(in: &cancellables)
        // When
        _ = sut.add(medicine: medicine, timeManager: TimeManager())
        subscription.cancel()
    }

    func test_cycleDateRangesWhenCreated() {
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail("test_cycleDateRangesWhenCreated")
            return
        }
        let cycles = sut.getCycleDatesStr(medicine: createdMedicine)
        guard cycles.count == 5 else {
            XCTFail("cycles.count != 5")
            return
        }
        XCTAssertEqual(cycles[0], "01/03/2020")
        XCTAssertEqual(cycles[1], "02/03/2020")
        XCTAssertEqual(cycles[2], "03/03/2020")
        XCTAssertEqual(cycles[3], "04/03/2020")
        XCTAssertEqual(cycles[4], "05/03/2020")
    }

    func test_cycleDateRangesAfterTakeDose() {
        var testFinished = false
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail("test_cycleDateRangesAfterTakeDose")
            return
        }
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 48)) //3-March-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        let suscripiton = sut.getMedicinesPublisher().sink(receiveCompletion: { _ in
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
        })
        suscripiton.store(in: &cancellables)
        sut.flushMedicines()
        suscripiton.cancel()
    }

    func test_cycleDateRangesAfterTwoTakeDose() {
        var testFinished = false
        sut = MedicineInteractor(dataManager: DataManager.shared)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800)) //1-March-2020
        let medicine = Medicine(name: "a",
                                unitsBox: 5,
                                intervalSecs: 3600 * 24,
                                unitsDose: 1)
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail("test_cycleDateRangesAfterTwoTakeDose")
            return
        }
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 48)) //3-March-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        let subscription = sut.getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard let medicine = someValue.first, !testFinished else { return }
                let cycles = self.sut.getCycleDatesStr(medicine: medicine)
                guard cycles.count == 5 else {
                    XCTFail("cycles.count != 5")
                    return
                }
                XCTAssertEqual(cycles[0], "03/03/2020")
                XCTAssertEqual(cycles[1], "04/03/2020")
                XCTAssertEqual(cycles[2], "05/03/2020")
                XCTAssertEqual(cycles[3], "06/03/2020")
                XCTAssertEqual(cycles[4], "07/03/2020")
                testFinished = true
            })
        subscription.store(in: &cancellables)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1583020800 + 3600 * 72)) //4-March-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        subscription.cancel()
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
        let subscription = sut.getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard expetedsIdx < expecteds.count else {
                    XCTFail("expetedsIdx < expecteds.count")
                    return
                }
                XCTAssertEqual(expecteds[expetedsIdx], someValue)
                expetedsIdx += 1
            })
        subscription.store(in: &cancellables)
        // When
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("test_removecycleWhenDataManagerReal")
            return
        }
        sut.remove(medicine: medicine2)
        sut.remove(medicine: createdMedicine)
        subscription.cancel()
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
        var testFinished = false
        sut = MedicineInteractor(dataManager: DataManager.shared)

        let medicine = Medicine(name: "a",
                                unitsBox: 10,
                                intervalSecs: 8,
                                unitsDose: 1)

        guard let createdMedicine = sut.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("test_updatecycleWhenDataManagerReal")
            return
        }
        let subscription = sut.getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard !testFinished else { return }
                guard let medicine = someValue.first else {
                    XCTFail("medicine = someValue.first")
                    return
                }
                XCTAssertEqual(medicine.name, "nameUpdated")
                XCTAssertEqual(medicine.unitsBox, 20)
                XCTAssertEqual(medicine.intervalSecs, 2)
                XCTAssertEqual(medicine.unitsDose, 2)
                testFinished = true
            })
        subscription.store(in: &cancellables)
        // When
        createdMedicine.name = "nameUpdated"
        createdMedicine.unitsBox = 20
        createdMedicine.intervalSecs = 2
        createdMedicine.unitsDose = 2
        sut.update(medicine: createdMedicine)
        subscription.cancel()
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
            XCTFail("test_getExpirationDayNumberWhen1")
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
            XCTFail("test_getExpirationDayNumberWhen29")
            return
        }
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
            XCTFail("test_getExpirationMonthYear")
            return
        }
        XCTAssertEqual(sut.getExpirationMonthYear(medicine: createdMedicine), "February - 2020")
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
            XCTFail("test_getExpirationWeekdayHourMinute")
            return
        }
        XCTAssertEqual(sut.getExpirationWeekdayHourMinute(medicine: createdMedicine), "Saturday - 01:00")
    }

    func test_takeDoseWhenMonoDose() {
        var testFinished = false
        sut = MedicineInteractor(dataManager: DataManager.shared)

        let medicine = Medicine(name: "a",
                                unitsBox: 2,
                                intervalSecs: 8,
                                unitsDose: 2)

        guard let createdMedicine = sut.add(medicine: medicine, timeManager: TimeManager()) else {
            XCTFail("test_takeDoseWhenMonoDose")
            return
        }

        let subscription = sut.getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard !testFinished else { return }
                guard let medicine = someValue.first else {
                    XCTFail("medicine = someValue.first")
                    return
                }
                guard !medicine.currentCycle.doses.isEmpty,
                    let firstDose = medicine.currentCycle.doses.first else {
                        XCTFail("firstDose = medicine.currentCycle.doses.first")
                        return
                }
                XCTAssertEqual(firstDose.expected, 1582934400)
                XCTAssertEqual(firstDose.real, 1582934400)
                testFinished = true
            })
        subscription.store(in: &cancellables)
        // When
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400)) //29-Feb-2020

        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        subscription.cancel()
    }

    func test_takeDoseWhenFirstDose() {
        sut = MedicineInteractor(dataManager: DataManager.shared)

        let medicine = Medicine(name: "a",
                                unitsBox: 2,
                                intervalSecs: 3600,
                                unitsDose: 1)

        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400)) //29-Feb-2020
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail("test_takeDoseWhenFirstDose")
            return
        }
        let subscription = sut.getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard let medicine = someValue.first else {
                    XCTFail("test_takeDoseWhenFirstDose")
                    return
                }
                guard medicine.currentCycle.doses.count == 1,
                    let lastDose = medicine.currentCycle.doses.last else {
                        XCTFail("test_takeDoseWhenFirstDose")
                        return
                }
                XCTAssertEqual(lastDose.expected, 1582934400)
                XCTAssertEqual(lastDose.real, 1582934400)
            })
        subscription.store(in: &cancellables)
        // When
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        subscription.cancel()
    }

    func test_takeDoseWhenLastDose() {
        sut = MedicineInteractor(dataManager: DataManager.shared)

        let medicine = Medicine(name: "a",
                                unitsBox: 2,
                                intervalSecs: 3600,
                                unitsDose: 1)

        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400)) //29-Feb-2020
        guard let createdMedicine = sut.add(medicine: medicine, timeManager: timeManager) else {
            XCTFail("test_takeDoseWhenLastDose")
            return
        }
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        let subscription = sut.getMedicinesPublisher()
            .sink(receiveCompletion: { _ in
                XCTFail(".sink() received the completion:")
            }, receiveValue: { someValue in
                guard let medicine = someValue.first else {
                    XCTFail("test_takeDoseWhenLastDose")
                    return
                }
                guard medicine.currentCycle.doses.count == 2,
                    let lastDose = medicine.currentCycle.doses.last else {
                        XCTFail("test_takeDoseWhenLastDose")
                        return
                }
                XCTAssertEqual(lastDose.expected, 1582934400 + 3600)
                XCTAssertEqual(lastDose.real, 1582934400 + 3600)
            })
        subscription.store(in: &cancellables)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1582934400 + 3600)) //29-Feb-2020
        sut.takeDose(medicine: createdMedicine, timeManager: timeManager)
        subscription.cancel()
    }

    func test_getIntervals_en() throws {
        // Update the language by swaping bundle
        Bundle.setLanguage(lang: "en")
        // When
        let intervals = sut.getIntervals()
        guard intervals.count == 9 else {
            XCTFail("test_getIntervals_en")
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

    func test_getIntervals_es() throws {
        // Update the language by swaping bundle
        Bundle.setLanguage(lang: "es")
        // When
        let intervals = sut.getIntervals()
        guard intervals.count == 9 else {
            XCTFail("test_getIntervals_en")
            return
        }
        XCTAssertEqual(intervals[0].secs, 30)
        XCTAssertEqual(intervals[0].label, "_30 Secs")
        XCTAssertEqual(intervals[1].secs, 3600)
        XCTAssertEqual(intervals[1].label, "1 Hora")
        XCTAssertEqual(intervals[2].secs, 7200)
        XCTAssertEqual(intervals[2].label, "2 Horas")
        XCTAssertEqual(intervals[3].secs, 14400)
        XCTAssertEqual(intervals[3].label, "4 Horas")
        XCTAssertEqual(intervals[4].secs, 21600)
        XCTAssertEqual(intervals[4].label, "6 Horas")
        XCTAssertEqual(intervals[5].secs, 28800)
        XCTAssertEqual(intervals[5].label, "8 Horas")
        XCTAssertEqual(intervals[6].secs, 43200)
        XCTAssertEqual(intervals[6].label, "12 Horas")
        XCTAssertEqual(intervals[7].secs, 86400)
        XCTAssertEqual(intervals[7].label, "1 Día")
        XCTAssertEqual(intervals[8].secs, 172800)
        XCTAssertEqual(intervals[8].label, "2 Días")
    }
}
