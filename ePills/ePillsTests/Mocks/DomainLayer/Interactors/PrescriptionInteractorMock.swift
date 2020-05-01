//
//  PrescriptionInteractorMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation

public final class PrescriptionInteractorMock:  PrescriptionInteractorProtocol {
    
    var addCount = 0
    var removeCount = 0
    
    public func add(prescription: Prescription) {
        addCount += 1
    }
    
    public func remove(prescription: Prescription) {
        removeCount += 1
    }
    
    
}
