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
    func remove(prescription: Prescription)
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
        prescriptions = prescriptions.sorted(by:{ $0.creation < $1.creation })
        subject.send(self.prescriptions)
    }
    
    func remove(prescription: Prescription) {
        
        if let index = prescriptions.firstIndex(where: {$0 == prescription}) {
          prescriptions.remove(at: index)
        } else{
            print("eing!!!")
        }
//        prescriptions = prescriptions
//       // .compactMap( { $0 == prescription ? nil : $0 })
//        .sorted(by:{ $0.creation < $1.creation })
//        prescriptions = prescriptions
//            .compactMap( { $0 == prescription ? nil : $0 })
//            .sorted(by:{ $0.creation < $1.creation })
        subject.send(self.prescriptions)
    }
    
    func getPrescriptions() -> AnyPublisher<[Prescription], Never> {
        prescriptions = prescriptions.sorted(by:{ $0.creation < $1.creation })
        subject.send(self.prescriptions)
        return subject.eraseToAnyPublisher()
    }
}

extension DataManager: Resetable {
    func reset() {
        self.prescriptions = []
        subject.send(self.prescriptions)
    }
}
