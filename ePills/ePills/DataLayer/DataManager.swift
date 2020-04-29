//
//  DataManager.swift
//  seco
//
//  Created by Javier Calatrava on 25/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol DataManagerProtocol {
    
    func add(prescription: Prescription)
    func getPrescriptions() -> AnyPublisher<[Prescription], Never>
}

final class DataManager {

    static let shared:DataManager = DataManager()
    
    private let subject = PassthroughSubject< [Prescription], Never>()
    private var prescriptions: [Prescription] = []

}

extension DataManager: DataManagerProtocol {
    
    func add(prescription: Prescription) {
        prescriptions.append(prescription)
        subject.send(self.prescriptions)
    }
    
    func getPrescriptions() -> AnyPublisher<[Prescription], Never> {
        subject.send(self.prescriptions)
        return subject.eraseToAnyPublisher()
    }
    
    private func sort() -> [Prescription] {
        self.prescriptions = self.prescriptions.sorted(by: { $0.creation < $1.creation })
        return self.prescriptions
    }
}

extension DataManager: Resetable {
    func reset() {
        self.prescriptions = []
    }
}
