//
//  MedicineCalendarVM.swift
//  ePills
//
//  Created by Javier Calatrava on 28/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit

public final class MedicineCalendarVM: ObservableObject {

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    var doseIntervals: [Date] = []

    let onScrollToExpirationDateSubject = PassthroughSubject<Void, Never>()

    @Published var expirationDayNumber: String
    @Published var expirationMonthYear: String
    @Published var expirationWeekdayHourMinute: String

    // MARK: Private attributes
    private var medicine: Medicine
    private var interactor: MedicineInteractorProtocol
    private var timeManager: TimeManagerProtocol

    // MARK: - Constructor
    init(medicine: Medicine,
         interactor: MedicineInteractorProtocol = MedicineInteractor(),
         timeManager: TimeManagerProtocol = TimeManager()) {
        self.medicine = medicine
        self.timeManager = timeManager
        self.interactor = interactor
        self.doseIntervals = interactor.getCycleDates(medicine: medicine)
        self.expirationDayNumber = interactor.getExpirationDayNumber(medicine: medicine)
        self.expirationMonthYear = interactor.getExpirationMonthYear(medicine: medicine)
        self.expirationWeekdayHourMinute = interactor.getExpirationWeekdayHourMinute(medicine: medicine)
    }

    func getMedicineName() -> String {
        return medicine.name
    }

    func getSelectionCicleType(date: Date,
                               isCurrentMonth: Bool,
                               timeManager: TimeManagerProtocol = TimeManager()) -> SelectionCicleType {
        guard isCurrentMonth else { return .dayOutOfMonth }
        guard doseIntervals.filter({ date.isSameDDMMYYYY(date: $0) }).count > 0 else { return .none }

        if doseIntervals.count == 1,
            let first = doseIntervals.first {
            if first.isSameDDMMYYYY(date: date) {
                return date.isSameDDMMYYYY(date: Date()) ? .dayCycleToday : .dayCycle
            } else {
                return .none
            }
        }

        if let first = doseIntervals.first,
            first.isSameDDMMYYYY(date: date) {
            if doseIntervals.count == 1 {
                return .unknown
            } else {
                if date.isSameDDMMYYYY(date: Date()) {
                    return .startTodayLongCycle
                } else {
                    return date > Date(timeIntervalSince1970: TimeInterval(timeManager.timeIntervalSince1970())) ?
                        .unknown : .startPastLongCycle
                }
            }
        } else if let last = doseIntervals.last,
            last.isSameDDMMYYYY(date: date) {
            if date.isSameDDMMYYYY(date: Date()) {
                return .endTodayLongCycle
            } else {
                return date > Date(timeIntervalSince1970: TimeInterval(timeManager.timeIntervalSince1970())) ?
                    .endFutureLongCycle : .endPastLongCycle
            }
        } else {
            if date.isSameDDMMYYYY(date: Date()) {
                return .midTodayLongCycle
            } else {
                return date > Date(timeIntervalSince1970: TimeInterval(timeManager.timeIntervalSince1970())) ?
                    .midFutureLongCycle : .midPastLongCycle
            }
        }
    }

    func getTodayCicleColor(date: Date, timeManager: TimeManagerProtocol = TimeManager()) -> UIColor {
        let date = date.dateFormatUTC()
        let todayDate = Date(timeIntervalSince1970: TimeInterval(timeManager.timeIntervalSince1970())).dateFormatUTC()

        return date == todayDate ? CalendarView.Colors.pastToday : UIColor.clear
    }
}
