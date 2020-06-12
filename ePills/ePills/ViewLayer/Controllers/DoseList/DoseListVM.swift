//
//  DoseListVM.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit

public final class DoseListVM: ObservableObject {

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()

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
    }

    // MARK: - Public helpers
    private func getRemainingTimeMessage(dose: Dose) -> (String, String) {
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
        let now: Date = Date(timeIntervalSince1970: TimeInterval(dose.expected))
        let nextDoseTimestamp = Date(timeIntervalSince1970: TimeInterval(dose.real))
        let timeDifference = Calendar.current.dateComponents(requestedComponent, from: nextDoseTimestamp, to: now)

        return interactor.timeDifference2Str(timeDifference: timeDifference)
    }

    func getDoses() -> [DoseCellViewModel] {
        var doseCellViewModel: [DoseCellViewModel] = []

        for (index, dose) in medicine.currentCycle.doses.enumerated() {
            let doseOrder = "\(self.medicine.unitsDose * (index + 1))/\(self.medicine.unitsBox)"
            let day = self.interactor.getExpirationRealDayNumber(dose: dose)
            let monthYear = self.interactor.getExpirationRealMonthYear(dose: dose)
            let weekdayHHMM = self.interactor.getExpirationRealWeekdayHourMinute(dose: dose)
            let realOffset = self.getRemainingTimeMessage(dose: dose)
            let realOffsetColorStr = realOffset.0.starts(with: "-") ? R.color.colorRed.name : R.color.colorWhite.name
            var doseCellType: DoseCellType = .monoCycle
            if medicine.currentCycle.doses.count == 2 {
                doseCellType = index == 0 ? .endToday : .startPast
            } else if medicine.currentCycle.doses.count > 2 {
                if index == 0 {
                    doseCellType = medicine.unitsBox <= medicine.currentCycle.unitsConsumed ? .endPast : .endToday
                } else if index == medicine.currentCycle.doses.count - 1 {
                    doseCellType = .startPast
                } else {
                    doseCellType = .middle
                }
            }

            doseCellViewModel.append(DoseCellViewModel(doseOrder: doseOrder,
                                                       day: day,
                                                       monthYear: monthYear,
                                                       weekdayHHMM: weekdayHHMM,
                                                       realOffset: "\(realOffset.0)",
                realOffsetColorStr: realOffsetColorStr,
                                                       doseCellType: doseCellType))
        }

        return doseCellViewModel
    }
}
