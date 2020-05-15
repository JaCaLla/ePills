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
    
    var prescription: Medicine?
    
    public func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol,
                                        medicine: Medicine?) {
        presentPrescriptionFormCount += 1
        self.prescription = medicine
    }
    
    public func replaceByFirstPrescription(interactor: PrescriptionInteractorProtocol) {
        replaceByFirstPrescriptionCount += 1
    }
    
    public func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol, isUpdate: Bool) {
        replaceByFirstPrescriptionCountIsUpdate += 1
    }
}
