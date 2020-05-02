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
    func remove(prescription: Prescription)
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
    @Published var selectedIntervalIndex = Interval(hours: 8, label: "8 Hours")
    @Published var unitsDose: String = "1"

    // MARK: - Private attributes
    private var interactor: PrescriptionInteractorProtocol
    @Published var prescription: Prescription?

    init(interactor: PrescriptionInteractorProtocol = PrescriptionInteractor(dataManager: DataManager.shared), prescription: Prescription?) {
        self.interactor = interactor
        self.prescription = prescription
        if let updatedPrescription = self.prescription/*,
            let name = updatedPrescription.name,
            let unitsBox = String(describing: updatedPrescription.unitsBox),
            let interval = updatedPrescription.interval,
            let unitsDose = String(describing: updatedPrescription.unitsDose)*/ {
            self.name = updatedPrescription.name
            self.unitsBox = "\(String(describing: updatedPrescription.unitsBox))"
            self.selectedIntervalIndex = updatedPrescription.interval //?? Interval(hours: 8, label: "8 Hours")
            self.unitsDose = "\(String(describing: updatedPrescription.unitsDose))"
        }
    }


}

extension PrescriptionFormVM: PrescriptionFormVMProtocol {
    func save() {
        if var updatedPrescription = self.prescription {
            updatedPrescription.name = self.name
            updatedPrescription.unitsBox = Int(self.unitsBox) ?? -1
            updatedPrescription.interval = self.selectedIntervalIndex
            updatedPrescription.unitsDose = Int(self.unitsDose) ?? -1
            interactor.update(prescription: updatedPrescription)
        } else {
            let prescription = Prescription(name: self.name,
                                            unitsBox: Int(self.unitsBox) ?? -1,
                                            interval: self.selectedIntervalIndex,
                                            unitsDose: Int(self.unitsDose) ?? -1)
            interactor.add(prescription: prescription)
        }
        onDismissSubject.send()
    }

    func remove(prescription: Prescription) {
        interactor.remove(prescription: prescription)
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
    func title() -> String {
        return  self.prescription == nil ?
                R.string.localizable.prescription_form_title.key.localized :
        R.string.localizable.prescription_form_title_update.key.localized
    }
}
