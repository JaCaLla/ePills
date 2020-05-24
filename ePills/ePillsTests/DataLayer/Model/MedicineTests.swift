//
//  MedicineTests.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 13/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import XCTest

class MedicineTests: XCTestCase {

     var sut: Medicine!

       override func setUpWithError() throws {

           sut = Medicine(name: "asdfg",
                              unitsBox: 20,
                              intervalSecs: 8 * 3600,
                              unitsDose: 2)
       }
    
    func test_defaultConstructor() throws {
           XCTAssertEqual(sut.name, "asdfg")
           XCTAssertEqual(sut.unitsBox, 20)
           XCTAssertEqual(sut.intervalSecs, 8 * 3600)
           XCTAssertEqual(sut.unitsDose, 2)
           XCTAssertEqual(sut.getState(), .notStarted)
        XCTAssertEqual(sut.currentCycle.unitsConsumed, 0)
        XCTAssertNil(sut.currentCycle.nextDose)
       }

    func test_prescriptionStarted() {
        // When
        let now = Int(Date().timeIntervalSince1970)
        sut.takeDose()
        // Then
        XCTAssertEqual(sut.getState(), .ongoing)
        XCTAssertEqual(sut.currentCycle.unitsConsumed, 2)
        XCTAssertEqual(sut.currentCycle.nextDose, now + 8 * 3600)
    }
    
    func test_prescriptionFinished() {
        // Given
        let timeManager = TimeManager()
        timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
        var now = 8 * 3600
        for _ in 1...9 {
            sut.takeDose(timeManager: timeManager)
            timeManager.setInjectedDate(date: Date(timeIntervalSince1970: TimeInterval(now)))
            now += 8 * 3600 * 24
            let state = sut.getState(timeManager: timeManager)
            XCTAssertTrue( state == .ongoingReady || state == .ongoingEllapsed)
        }
        // When
        sut.takeDose(timeManager: timeManager)
        // Then
        XCTAssertEqual(sut.getState(timeManager: timeManager), .finished)
        XCTAssertEqual(sut.currentCycle.unitsConsumed, 20)
    }
    
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
           sut.intervalSecs = 10
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
           sut.intervalSecs = 10
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
           sut.intervalSecs = 3600
           sut.unitsBox = 1
           sut.unitsDose = 1
           sut.takeDose(timeManager: timeManager)
           // Then
           XCTAssertEqual(sut.getState(timeManager: timeManager), .finished)
       }

       func test_nextDoseWhenNotStarted() {
           // Given
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           // When
           sut.takeDose(timeManager: timeManager)
           // Then
           XCTAssertEqual(sut.currentCycle.nextDose, 3600)
       }

       func test_nextDoseWhenStarted() {
           // Given
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           sut.takeDose(timeManager: timeManager)
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600))
           // When
           sut.takeDose(timeManager: timeManager)
           // Then
           XCTAssertEqual(sut.currentCycle.nextDose, 7200)
       }

       func test_nextDoseWhenFinished() {
           // Given
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           sut.unitsBox = 1
           sut.unitsDose = 1
           sut.takeDose(timeManager: timeManager)
           // When
           sut.takeDose(timeManager: timeManager)
           // Then
           XCTAssertNil(sut.currentCycle.nextDose)
       }

       func test_nextDoseWhenOngoing() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           // When
           sut.takeDose(timeManager: timeManager)
           // Then
           XCTAssertEqual(sut.currentCycle.nextDose, 8 * 3600)
       }

       func test_nextDoseWhenOngoingReady() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 10
           sut.takeDose(timeManager: timeManager)
           // When
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
           // Then
           XCTAssertEqual(sut.currentCycle.nextDose, 10)
       }

       func test_nextDoseWhenOngoingEllapsed() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 10
           sut.takeDose(timeManager: timeManager)
           // When
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
           // Then
           XCTAssertEqual(sut.currentCycle.nextDose, 10)
       }

       func test_getRemainingWhenNotStarted() {
           // Given
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           // When
           sut.takeDose(timeManager: timeManager)
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 1000))
           // Then
           let remaining = sut.currentCycle.getRemaining(timeManager: timeManager)
           XCTAssertEqual(remaining, -2600)
       }

       func test_getRemainingWhenStarted() {
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           sut.takeDose(timeManager: timeManager)
           // When
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 3600))
           sut.takeDose(timeManager: timeManager)
           // Then
           let remaining = sut.currentCycle.getRemaining(timeManager: timeManager)
           XCTAssertEqual(remaining, -3600)
       }

       func test_getRemainingWhenFinished() {
           // Given
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           sut.unitsBox = 1
           sut.unitsDose = 1
           sut.takeDose(timeManager: timeManager)
           // When
           // Then
           XCTAssertNil(sut.currentCycle.getRemaining(timeManager: timeManager))
       }

       func test_getRemainingWhenOngoing() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           // When
           sut.takeDose(timeManager: timeManager)
           // Then
           XCTAssertEqual(sut.currentCycle.getRemaining(timeManager: timeManager), -8 * 3600)
       }

       func test_getRemainingWhenOngoingReady() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 10
           sut.takeDose(timeManager: timeManager)
           // When
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 9))
           // Then
           XCTAssertEqual(sut.currentCycle.getRemaining(timeManager: timeManager), -1)
       }

       func test_getRemainingWhenOngoingEllapsed() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 10
           sut.takeDose(timeManager: timeManager)
           // When
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 11))
           // Then
           XCTAssertEqual(sut.currentCycle.getRemaining(timeManager: timeManager), 1)
       }

       func test_getRemainingMins() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))

           sut.currentCycle.nextDose = nil
           sut.intervalSecs = 59
           XCTAssertNil(sut.currentCycle.getRemainingMins(timeManager: timeManager))
           sut.takeDose(timeManager: timeManager)
           XCTAssertEqual(sut.currentCycle.getRemainingMins(timeManager: timeManager), 0)

           sut.currentCycle.nextDose = nil
           sut.intervalSecs = 60
           sut.takeDose(timeManager: timeManager)
           XCTAssertEqual(sut.currentCycle.getRemainingMins(timeManager: timeManager), -1)
       }

       func test_getRemainingHours() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))

           sut.currentCycle.nextDose = nil
           sut.intervalSecs = 3559
           XCTAssertNil(sut.currentCycle.getRemainingMins(timeManager: timeManager))
           sut.takeDose(timeManager: timeManager)
           XCTAssertEqual(sut.currentCycle.getRemainingHours(timeManager: timeManager), 0)

           sut.currentCycle.nextDose = nil
           sut.intervalSecs = 3600
           sut.takeDose(timeManager: timeManager)
           XCTAssertEqual(sut.currentCycle.getRemainingHours(timeManager: timeManager), -1)
       }

       func test_getRemainingDays() {
           // Given
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))

           sut.currentCycle.nextDose = nil
           sut.intervalSecs = 86399
           XCTAssertNil(sut.currentCycle.getRemainingMins(timeManager: timeManager))
           sut.takeDose(timeManager: timeManager)
           XCTAssertEqual(sut.currentCycle.getRemainingDays(timeManager: timeManager), 0)

           sut.currentCycle.nextDose = nil
           sut.intervalSecs = 86400
           sut.takeDose(timeManager: timeManager)
           XCTAssertEqual(sut.currentCycle.getRemainingDays(timeManager: timeManager), -1)
       }
       
       func test_isLastOrLastPrescription() {
           XCTAssertTrue(sut.isFirst())
           XCTAssertFalse(sut.isLast())
           
           XCTAssertNil(sut.currentCycle.nextDose)
           let timeManager = TimeManager()
           timeManager.setInjectedDate(date: Date(timeIntervalSince1970: 0))
           sut.intervalSecs = 3600
           sut.unitsBox = 1
           sut.unitsDose = 1
           sut.takeDose(timeManager: timeManager)
           
           XCTAssertFalse(sut.isFirst())
           XCTAssertTrue(sut.isLast())
       }
}
