//
//  PrescriptionInteractorMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation
import Combine

public final class MedicineInteractorMock: MedicineInteractorProtocol {

    var addCount = 0
    var removeCount = 0
    var updateCount = 0
    var takeDoseCount = 0
    var getCurrentPrescriptionIndexCount = 0
    var getPrescriptionsCount = 0
    var getIntervalsCount = 0
    var flushMedicinesCount = 0
    var getCycleDatesStr = 0
    var getCycleDatesCount = 0
    var getExpirationDayNumberCount = 0
    var getExpirationMonthYearCount = 0
    var getExpirationWeekdayHourMinuteCount = 0
    var getExpirationDoseDayNumberCount = 0
    var getExpirationDoseMonthYearCount = 0
    var getExpirationDoseWeekdayHourMinuteCount = 0
    var timeDifference2StrCount = 0
    var getExpirationHourMinuteCount = 0

    public func getCycleDates(medicine: Medicine) -> [Date] {
        getCycleDatesCount += 1
        return []
    }

    public func add(medicine: Medicine, timeManager: TimeManagerProtocol) -> Medicine? {
        addCount += 1
        return nil
    }

    public func remove(medicine: Medicine) {
        removeCount += 1
    }

    public func update(medicine: Medicine) {
        updateCount += 1
    }
    public func getCurrentPrescriptionIndex() -> AnyPublisher<Int, Never> {
        getCurrentPrescriptionIndexCount += 1
        return Just(0).eraseToAnyPublisher()
    }

    public func getMedicinesPublisher() -> AnyPublisher<[Medicine], Never> {
        getPrescriptionsCount += 1
        return Just([]).eraseToAnyPublisher()
    }

    public func takeDose(medicine: Medicine, onComplete: @escaping (Bool) -> Void) {
        takeDoseCount += 1
    }

    public func takeDose(medicine: Medicine, timeManager: TimeManagerProtocol) {
        takeDoseCount += 1
    }

    public func getIntervals() -> [Interval] {
        getIntervalsCount += 1
        return []
    }

    public func flushMedicines() {
        flushMedicinesCount += 1
    }

    public func getCycleDatesStr(medicine: Medicine) -> [String] {
        getCycleDatesStr += 1
        return []
    }

    public func getCycleDatesStr(medicine: Medicine) -> [[String]] {
        return []
    }

    public func getExpirationDayNumber(medicine: Medicine) -> String {
        getExpirationDayNumberCount += 1
        return ""
    }

    public func getExpirationMonthYear(medicine: Medicine) -> String {
        getExpirationMonthYearCount += 1
        return ""
    }

    public func getExpirationWeekdayHourMinute(medicine: Medicine) -> String {
        getExpirationWeekdayHourMinuteCount += 1
        return ""
    }

    public func getExpirationRealDayNumber(dose: Dose) -> String {
        getExpirationDoseDayNumberCount += 1
        return ""
    }

    public func getExpirationRealMonthYear(dose: Dose) -> String {
        getExpirationDoseMonthYearCount += 1
        return ""
    }

    public func getExpirationRealWeekdayHourMinute(dose: Dose) -> String {
        getExpirationDoseWeekdayHourMinuteCount += 1
        return ""
    }

    public func timeDifference2Str(timeDifference: DateComponents) -> (String, String) {
        timeDifference2StrCount += 1
        return ("", "")
    }

    public func getExpirationHourMinute(medicine: Medicine) -> String {
        getExpirationHourMinuteCount += 1
        return ""
    }
}
