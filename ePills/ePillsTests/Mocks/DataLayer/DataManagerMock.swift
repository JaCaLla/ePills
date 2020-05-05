//
//  DataManagerMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation
import Combine

class DataManagerMock: DataManagerProtocol {

    var addCount: Int = 0
    var removeCount: Int = 0
    var getPrescriptionsCount: Int = 0
    var updateCount: Int = 0

    func add(prescription: Prescription) {
        addCount += 1
    }

    func remove(prescription: Prescription) {
        removeCount += 1
    }
    
    func update(prescription: Prescription) {
        updateCount += 1
    }

    func getPrescriptions() -> AnyPublisher<[Prescription], Never> {
        getPrescriptionsCount += 1
        return Just([]).eraseToAnyPublisher()
    }
}
