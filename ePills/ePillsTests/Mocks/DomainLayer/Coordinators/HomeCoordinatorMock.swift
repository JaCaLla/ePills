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
    
    public func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol) {
        presentPrescriptionFormCount += 1
    }
}
