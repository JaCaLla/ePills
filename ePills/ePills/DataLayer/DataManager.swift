//
//  DataManager.swift
//  seco
//
//  Created by Javier Calatrava on 25/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

protocol DataManagerProtocol {
    func add(prescription: Prescription)
    func getPrescriptions() -> [Prescription]
}

final class DataManager {

    static let shared:DataManager = DataManager()
    
    var prescriptions:[Prescription] = []

}

extension DataManager: DataManagerProtocol {
    func add(prescription: Prescription) {
        prescriptions.append(prescription)
    }
    
    func getPrescriptions() -> [Prescription] {
        return self.prescriptions
    }
}

extension DataManager: Resetable {
    func reset() {
        self.prescriptions = []
    }
}
