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
    var updateCount: Int = 0
    var getPrescriptionsCount: Int = 0

    func add(medicine: Medicine) {
        addCount += 1
    }

    func remove(medicine: Medicine) {
        removeCount += 1
    }

    func update(medicine: Medicine) {
        updateCount += 1
    }

    func getMedicines() -> AnyPublisher<[Medicine], Never> {
        getPrescriptionsCount += 1
        return Just([]).eraseToAnyPublisher()
    }
}
