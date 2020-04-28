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

  //  @Published private(set) var prescriptions: [Prescription] = []
    
    private let subject = PassthroughSubject< [Prescription], Never>()
     var prescriptions2: [Prescription] = []

}

extension DataManager: DataManagerProtocol {
    
    
    func add(prescription: Prescription) {
    //    prescriptions.append(prescription)
        prescriptions2.append(prescription)
        subject.send(self.prescriptions2)
    }
    
    func getPrescriptions() -> AnyPublisher<[Prescription], Never> {
        
        subject.send(self.prescriptions2)
        return subject.eraseToAnyPublisher()
    }
    
    
    
    private func sort() -> [Prescription] {
        self.prescriptions2 = self.prescriptions2.sorted(by: { $0.creation < $1.creation })
        return self.prescriptions2
    }
}

extension DataManager: Resetable {
    func reset() {
        self.prescriptions2 = []
    }
}
