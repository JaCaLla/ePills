//
//  HomeCoordinatorMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 30/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation

public final class HomeCoordinatorMock: HomeCoordinatorProtocol {

    var presentPrescriptionFormCount = 0
    var replaceByFirstPrescriptionCount = 0
    var replaceByFirstPrescriptionCountIsUpdate = 0
    var presentCalendarCount = 0
    var presentDoseListCount = 0

    var prescription: Medicine?

    public func presentPrescriptionForm(interactor: MedicineInteractorProtocol,
                                        medicine: Medicine?) {
        presentPrescriptionFormCount += 1
        self.prescription = medicine
    }

    public func replaceByFirstPrescription(interactor: MedicineInteractorProtocol) {
        replaceByFirstPrescriptionCount += 1
    }

    public func presentPrescriptionForm(interactor: MedicineInteractorProtocol, isUpdate: Bool) {
        replaceByFirstPrescriptionCountIsUpdate += 1
    }

    public func presentCalendar(interactor: MedicineInteractorProtocol, medicine: Medicine) {
        presentCalendarCount += 1
    }

    public func presentDoseList(interactor: MedicineInteractorProtocol, medicine: Medicine) {
        presentDoseListCount += 1
    }
}
