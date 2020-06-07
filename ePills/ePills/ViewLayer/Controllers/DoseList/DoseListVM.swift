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
//        guard medicines.count > currentPage else { return ("", "") }
//        let medicine = self.medicines[currentPage]
//
//        guard let nextDose = medicine.getNextDose() else { return ("", "") }
        let requestedComponent: Set<Calendar.Component> = [.year, .month, .day, .hour, .minute, .second]
//        let tmpTimeManager = timeManager ?? TimeManager()
        let now: Date = Date(timeIntervalSince1970: TimeInterval(dose.expected))
        let nextDoseTimestamp = Date(timeIntervalSince1970: TimeInterval(dose.real))
        let timeDifference = Calendar.current.dateComponents(requestedComponent, from: nextDoseTimestamp, to: now)

        return interactor.timeDifference2Str(timeDifference: timeDifference)
    }
    
    func getDoses() -> [DoseCellViewModel] {
        var doseCellViewModel: [DoseCellViewModel] = []
        
        for (index, dose) in medicine.currentCycle.doses.enumerated() {
            let doseOrder = "\(self.medicine.unitsDose * (index + 1))/\(self.medicine.unitsBox)"
            let day = self.interactor.getExpirationDayNumber(dose: dose)
            let monthYear = self.interactor.getExpirationMonthYear(dose: dose)
            let weekdayHHMM = self.interactor.getExpirationWeekdayHourMinute(dose: dose)
            let realOffset = self.getRemainingTimeMessage(dose: dose)
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
                                                      doseCellType: doseCellType))
        }
        
        return doseCellViewModel

        /*
               //BiCycle not finished
        return  [DoseCellViewModel(doseOrder: "1/2", day: "1", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", realOffsetColorStr: R.color.colorRed.name, doseCellType: .endToday),
                 DoseCellViewModel(doseOrder: "2/2", day: "2", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .startPast)]
        */
        // Monocyle
       // return  [DoseCellViewModel(day: "1", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .monoCycle, isFirst: true)]
        
        /* //Cycle finished
        return  [DoseCellViewModel(day: "1", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .endPast, isFirst: true),
                 DoseCellViewModel(day: "2", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .middle),
        DoseCellViewModel(day: "3", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .middle),
        DoseCellViewModel(day: "4", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .middle),
        DoseCellViewModel(day: "5", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .startPast, isLast: true)]
 */
        
        /* //Cycle not finished
        return  [DoseCellViewModel(day: "1", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .endToday, isFirst: true),
                 DoseCellViewModel(day: "2", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .middle),
        DoseCellViewModel(day: "3", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .middle),
        DoseCellViewModel(day: "4", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .middle),
        DoseCellViewModel(day: "5", monthYear: "Junio - 2020", weekdayHHMM: "Viernes - 06:04", realOffset: "-1d 3h", doseCellType: .startPast, isLast: true)]
 */
    }
}
