//
//  PrescriptionInteractorMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 29/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation
import Combine

public final class PrescriptionInteractorMock:  PrescriptionInteractorProtocol {

    var addCount = 0
    var removeCount = 0
    var updateCount = 0
    var takeDoseCount = 0
    var getCurrentPrescriptionIndexCount = 0
    var getPrescriptionsCount = 0
    
    public func add(prescription: Prescription) {
        addCount += 1
    }
    
    public func remove(prescription: Prescription) {
        removeCount += 1
    }
    
    public func update(prescription: Prescription) {
        updateCount += 1
    }
    public func getCurrentPrescriptionIndex() -> AnyPublisher<Int, Never> {
        getCurrentPrescriptionIndexCount += 1
        return Just(0).eraseToAnyPublisher()
    }
    
    public func getPrescriptions() -> AnyPublisher<[Prescription], Never> {
        getPrescriptionsCount += 1
        return Just([]).eraseToAnyPublisher()
    }
    
    public func takeDose(prescription: Prescription, onComplete: @escaping (Bool) -> Void) {
        takeDoseCount += 1
    }    
}
