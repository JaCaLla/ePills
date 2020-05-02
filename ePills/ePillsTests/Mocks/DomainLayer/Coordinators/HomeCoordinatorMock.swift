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
    public func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol, isUpdate: Bool) {
        
    }
    

    var presentPrescriptionFormCount = 0
    var replaceByFirstPrescriptionCount = 0
    
    var prescription: Prescription?
    
    public func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol,
                                        prescription: Prescription?) {
        presentPrescriptionFormCount += 1
        self.prescription = prescription
    }
    
    public func replaceByFirstPrescription(interactor: PrescriptionInteractorProtocol) {
        replaceByFirstPrescriptionCount += 1
    }
}
