//
//  DataManagerMock.swift
//  ePillsTests
//
//  Created by Javier Calatrava on 25/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//
@testable import ePills
import Foundation

class DataManagerMock: DataManagerProtocol {

    var addCount: Int = 0
    var getPrescriptionsCount: Int = 0
    
    func add(prescription: Prescription) {
        addCount += 1
    }
    
    func getPrescriptions() -> [Prescription] {
        getPrescriptionsCount += 1
        return []
    }
}