//
//  PrescriptionTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 26/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class PrescriptionTests: XCTestCase {

    var sut: Prescription!

    override func setUpWithError() throws {

        sut = Prescription(name: "asdfg",
                           unitsBox: 20,
                           interval: Interval(secs: 8 * 3600, label: "8 hours"),
                           unitsDose: 2)
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_defaultConstructor() throws {
        XCTAssertEqual(sut.name, "asdfg")
        XCTAssertEqual(sut.unitsBox, 20)
        XCTAssertEqual(sut.interval, Interval(secs: 8 * 3600, label: "8 hours"))
        XCTAssertEqual(sut.unitsDose, 2)
        XCTAssertEqual(sut.getState(), .notStarted)
        XCTAssertEqual(sut.unitsConsumed, 0)
        XCTAssertNil(sut.nextDose)
    }

    func test_prescriptionStarted() {
        // When
        let now = Int(Date().timeIntervalSince1970)
        sut.takeDose()
        // Then
        XCTAssertEqual(sut.getState(), .ongoing)
        XCTAssertEqual(sut.unitsConsumed, 2)
        XCTAssertEqual(sut.nextDose, now + 8 * 3600)
    }

    func test_prescriptionFinished() {
        // Given
        for _ in 1...9 {
            sut.takeDose()
            XCTAssertEqual(sut.getState(), .ongoing)
        }
        // When
        sut.takeDose()
        // Then
        XCTAssertEqual(sut.getState(), .finished)
        XCTAssertEqual(sut.unitsConsumed, 20)
    }

//    func test_title() {
//        XCTAssertEqual(sut.title(), "asdfg [0/20]")
//    }

    func test_getStateWhenNotStarted() {
        XCTAssertEqual(sut.getState(), .notStarted)
    }

    func test_getStateWhenOngoing() {
        // When
        sut.takeDose()
        // Then
        XCTAssertEqual(sut.getState(), .ongoing)
    }

    func test_getStateWhenOngoingReady() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 10, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
        // Then
        XCTAssertEqual(sut.getState(timeManager: timeManager), .ongoingReady)

    }

    func test_getStateWhenOngoingEllapsed() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 10, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
        // Then
        XCTAssertEqual(sut.getState(timeManager: timeManager), .ongoingEllapsed)

    }

    func test_getStateWhenFinished() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        sut.unitsBox = 1
        sut.unitsDose = 1
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.getState(timeManager: timeManager), .finished)
    }

    func test_nextDoseWhenNotStarted() {
        // Given
        XCTAssertNil(sut.nextDose)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        // When
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.nextDose, 3600)
    }

    func test_nextDoseWhenStarted() {
        // Given
        XCTAssertNil(sut.nextDose)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.nextDose, 7200)
    }

    func test_nextDoseWhenFinished() {
        // Given
        XCTAssertNil(sut.nextDose)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        sut.unitsBox = 1
        sut.unitsDose = 1
        sut.takeDose(timeManager: timeManager)
        // When
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertNil(sut.nextDose)
    }

    func test_nextDoseWhenOngoing() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        // When
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.nextDose, 8 * 3600)
    }

    func test_nextDoseWhenOngoingReady() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 10, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
        // Then
        XCTAssertEqual(sut.nextDose, 10)
    }

    func test_nextDoseWhenOngoingEllapsed() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 10, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
        // Then
        XCTAssertEqual(sut.nextDose, 10)
    }

    func test_getRemainingWhenNotStarted() {
        // Given
        XCTAssertNil(sut.nextDose)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        // When
        sut.takeDose(timeManager: timeManager)
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1000))
        // Then
        let remaining = sut.getRemaining(timeManager: timeManager)
        XCTAssertEqual(remaining, -2600)
    }

    func test_getRemainingWhenStarted() {
        XCTAssertNil(sut.nextDose)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600))
        sut.takeDose(timeManager: timeManager)
        // Then
        let remaining = sut.getRemaining(timeManager: timeManager)
        XCTAssertEqual(remaining, -3600)
    }

    func test_getRemainingWhenFinished() {
        // Given
        XCTAssertNil(sut.nextDose)
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 3600, label: "1 hour")
        sut.unitsBox = 1
        sut.unitsDose = 1
        sut.takeDose(timeManager: timeManager)
        // When
        // Then
        XCTAssertNil(sut.getRemaining(timeManager: timeManager))
    }

    func test_getRemainingWhenOngoing() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        // When
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.getRemaining(timeManager: timeManager), -8 * 3600)
    }

    func test_getRemainingWhenOngoingReady() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 10, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
        // Then
        XCTAssertEqual(sut.getRemaining(timeManager: timeManager), -1)
    }

    func test_getRemainingWhenOngoingEllapsed() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        sut.interval = Interval(secs: 10, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        // When
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
        // Then
        XCTAssertEqual(sut.getRemaining(timeManager: timeManager), 1)
    }

    func test_getRemainingMins() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))

        sut.nextDose = nil
        sut.interval = Interval(secs: 59, label: "1 hour")
        XCTAssertNil(sut.getRemainingMins(timeManager: timeManager))
        sut.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingMins(timeManager: timeManager), 0)

        sut.nextDose = nil
        sut.interval = Interval(secs: 60, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingMins(timeManager: timeManager), -1)
    }

    func test_getRemainingHours() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))

        sut.nextDose = nil
        sut.interval = Interval(secs: 3559, label: "1 hour")
        XCTAssertNil(sut.getRemainingMins(timeManager: timeManager))
        sut.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingHours(timeManager: timeManager), 0)

        sut.nextDose = nil
        sut.interval = Interval(secs: 3600, label: "1 hour")
        sut.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingHours(timeManager: timeManager), -1)
    }

    func test_getRemainingDays() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))

        sut.nextDose = nil
        sut.interval = Interval(secs: 86399, label: "1 day")
        XCTAssertNil(sut.getRemainingMins(timeManager: timeManager))
        sut.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingDays(timeManager: timeManager), 0)

        sut.nextDose = nil
        sut.interval = Interval(secs: 86400, label: "1 day")
        sut.takeDose(timeManager: timeManager)
        XCTAssertEqual(sut.getRemainingDays(timeManager: timeManager), -1)
    }
}
