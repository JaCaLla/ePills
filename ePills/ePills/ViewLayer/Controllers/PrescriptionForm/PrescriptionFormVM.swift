//
//  PrescriptionFormVM.swift
//  ePills
//
//  Created by Javier Calatrava on 22/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol PrescriptionFormVMProtocol {
    func getIntervals() -> [Interval]
    func save()
}

public final class PrescriptionFormVM: ObservableObject {

    @Published var name: String = ""
    @Published var unitsBox: String = ""
    @Published var selectedIntervalIndex = Interval(hours: 8, label: "8 Hours")
    @Published var unitsDose: String = "1"

    // MARK: - Private attributes
    var interactor: PrescriptionInteractorProtocol = PrescriptionInteractor()
    var dataManager: DataManagerProtocol

    init(interactor: PrescriptionInteractorProtocol = PrescriptionInteractor(),
         dataManager: DataManagerProtocol) {
        self.interactor = interactor
        self.dataManager = dataManager
    }


}

extension PrescriptionFormVM: PrescriptionFormVMProtocol {
    func save() {
        let prescription = Prescription(name: self.name,
                                        unitsBox: self.unitsBox,
                                        selectedIntervalIndex: self.selectedIntervalIndex,
                                        unitsDose: self.unitsDose)
        dataManager.add(prescription: prescription)
    }

    func getIntervals() -> [Interval] {

        var invervals: [Interval] = []
        invervals.append(contentsOf: [1].map {
            Interval(hours: $0,
                     label: "\($0) \(R.string.localizable.prescription_form_interval_list_hour.key.localized)") })
        invervals.append(contentsOf: [2, 4, 6, 8, 12, 16].map {
            Interval(hours: $0,
                     label: "\($0) \(R.string.localizable.prescription_form_interval_list_hours.key.localized)") })
        invervals.append(contentsOf: [1].map {
            Interval(hours: $0,
                     label: "\($0) \(R.string.localizable.prescription_form_interval_list_day.key.localized)") })
        return invervals
    }
}
