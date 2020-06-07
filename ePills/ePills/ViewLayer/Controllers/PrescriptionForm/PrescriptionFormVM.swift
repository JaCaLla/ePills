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
    func getInterval(intervalSecs: Int) -> Interval
    func save()
    func remove(medicine: Medicine)
    func title() -> String
}

public final class PrescriptionFormVM: ObservableObject {

    // MARK: - Publishers
    var onDismissPublisher: AnyPublisher<Void, Never> {
        return onDismissSubject.eraseToAnyPublisher()
    }
    private var onDismissSubject = PassthroughSubject<Void, Never>()

    @Published var name: String = ""
    @Published var unitsBox: String = ""
    @Published var selectedIntervalIndex = Interval(secs: 8 * 3600, label: "8 Hours")
    @Published var unitsDose: String = "1"

    // MARK: - Private attributes
    private var interactor: MedicineInteractorProtocol
    @Published var medicine: Medicine?

    init(interactor: MedicineInteractorProtocol = MedicineInteractor(dataManager: DataManager.shared), medicine: Medicine?) {
        self.interactor = interactor
        self.medicine = medicine
        if let updatedMedicine = self.medicine {
            self.name = updatedMedicine.name
            self.unitsBox = "\(String(describing: updatedMedicine.unitsBox))"
            self.selectedIntervalIndex = self.getInterval(intervalSecs: updatedMedicine.intervalSecs)
            self.unitsDose = "\(String(describing: updatedMedicine.unitsDose))"
        }
    }
}

extension PrescriptionFormVM: PrescriptionFormVMProtocol {

    func save() {
        if let updatedCycle = self.medicine {
            updatedCycle.name = self.name
            updatedCycle.unitsBox = Int(self.unitsBox) ?? -1
            //updatedCycle.interval = self.selectedIntervalIndex
            updatedCycle.intervalSecs = self.selectedIntervalIndex.secs
            updatedCycle.unitsDose = Int(self.unitsDose) ?? -1
            interactor.update(medicine: updatedCycle)
        } else {
            let medicine = Medicine(name: self.name,
                                            unitsBox: Int(self.unitsBox) ?? -1,
                                            intervalSecs: self.selectedIntervalIndex.secs,
                                            unitsDose: Int(self.unitsDose) ?? -1)
            interactor.add(medicine: medicine, timeManager: TimeManager())
        }
        onDismissSubject.send()
    }

    func remove(medicine: Medicine) {
        interactor.remove(medicine: medicine)
    }

    func getIntervals() -> [Interval] {
        return interactor.getIntervals()
    }
    
    func getInterval(intervalSecs: Int) -> Interval {
        guard let interval = self.getIntervals().first(where:{ $0.secs == intervalSecs }) else {
            return Interval(secs: intervalSecs, label: "\(intervalSecs/3600) _hour(s)")
        }
        return interval
    }
    
    func title() -> String {
        return  self.medicine == nil ?
                R.string.localizable.prescription_form_title.key.localized :
        R.string.localizable.prescription_form_title_update.key.localized
    }
}
