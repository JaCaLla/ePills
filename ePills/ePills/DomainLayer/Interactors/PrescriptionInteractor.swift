//
//  PrescriptionInteractor.swift
//  ePills
//
//  Created by Javier Calatrava on 24/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol PrescriptionInteractorProtocol {

    func add(prescription: Prescription)
    func remove(prescription: Prescription)
    func getCurrentPrescriptionIndex() -> Int
}


final class PrescriptionInteractor {

    // MARK: - Read only attributes
    private(set) var dataManager: DataManagerProtocol

    // MARK: - Private attributes
    @Published private(set) var prescriptions: [Prescription] = []
    private var cancellables = Set<AnyCancellable>()
    private var currentPrescriptionIndex: Int = 0

    init(dataManager: DataManagerProtocol = DataManager.shared) {
        self.dataManager = dataManager
        self.dataManager.getPrescriptions()
            .sink { prescriptions in
                self.prescriptions = prescriptions
            }.store(in: &cancellables)
    }
}

// MARK: - PrescriptionInteractorProtocol
extension PrescriptionInteractor: PrescriptionInteractorProtocol {

    func add(prescription: Prescription) {
        dataManager.add(prescription: prescription)
        if let index = prescriptions.firstIndex(of: prescription) {
            currentPrescriptionIndex = index
        }
    }

    func remove(prescription: Prescription) {
        dataManager.remove(prescription: prescription)
        currentPrescriptionIndex = 0
    }
    
    func getCurrentPrescriptionIndex() -> Int {
        return currentPrescriptionIndex
    }
}
