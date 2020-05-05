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
    @Published var selectedIntervalIndex = Interval(secs: 8 * 3600, label: "8 Hours")
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
        
        let secsPerHour = 3600
        
        var invervals: [Interval] = []
        invervals.append(Interval(secs: 10, label: "_10 Secs"))
        invervals.append(Interval(secs: 1 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_1_hour.key.localized))
        invervals.append(Interval(secs: 2 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_2_hours.key.localized))
        invervals.append(Interval(secs: 4 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_4_hours.key.localized))
        invervals.append(Interval(secs: 6 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_6_hours.key.localized))
        invervals.append(Interval(secs: 8 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_8_hours.key.localized))
        invervals.append(Interval(secs: 12 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_12_hours.key.localized))
        invervals.append(Interval(secs: 24 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_1_day.key.localized))
        invervals.append(Interval(secs: 48 * secsPerHour, label: R.string.localizable.prescription_form_interval_list_2_days.key.localized))
        
        return invervals
        /*
         "prescription_form_interval_list_1_hour" = "1 hour";
         "prescription_form_interval_list_2_hour" = "2 hours";
         "prescription_form_interval_list_3_hour" = "3 hours";
         "prescription_form_interval_list_4_hour" = "4 hours";
         "prescription_form_interval_list_6_hour" = "6 hours";
         "prescription_form_interval_list_8_hour" = "8 hours";
         "prescription_form_interval_list_12_hour" = "12 hours";
         "prescription_form_interval_list_1_day" = "1 day";
         "prescription_form_interval_list_2_days" = "2 days";
        */
//        invervals.append(contentsOf: [1.0 / 128.0 ,1.0].map {
//            Interval(hours: $0,
//                     label: "\($0) \(R.string.localizable.prescription_form_interval_list_hour.key.localized)") })
//        invervals.append(contentsOf: [2.0, 4.0, 6.0, 8.0, 12.0, 16.0].map {
//            Interval(hours: $0,
//                     label: "\($0) \(R.string.localizable.prescription_form_interval_list_hours.key.localized)") })
//        invervals.append(contentsOf: [24.0].map {
//            Interval(hours: $0,
//                     label: "\($0) \(R.string.localizable.prescription_form_interval_list_day.key.localized)") })
//        return invervals
    }
}
