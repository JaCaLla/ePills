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
    var interactor: PrescriptionInteractorProtocol //= PrescriptionInteractor(dataManager: DataManager.shared)
    //var firstPresciptionCoordinator: FirstPresciptionCoordinator
//    var dataManager: DataManagerProtocol

    init(interactor: PrescriptionInteractorProtocol = PrescriptionInteractor(dataManager: DataManager.shared)/*,
          coordinator: FirstPresciptionCoordinator*/) {
        self.interactor = interactor
   //     self.firstPresciptionCoordinator = coordinator
    }


}

extension PrescriptionFormVM: PrescriptionFormVMProtocol {
    func save() {
        let prescription = Prescription(name: self.name,
                                        unitsBox: Int(self.unitsBox) ?? -1,
                                        interval: self.selectedIntervalIndex,
                                        unitsDose: Int(self.unitsDose) ?? -1)
      //  dataManager.add(prescription: prescription)
        interactor.add(prescription: prescription)
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
}
