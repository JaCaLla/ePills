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
    func getCurrentPrescriptionIndex()  -> AnyPublisher<Int, Never>
    func getPrescriptions() -> AnyPublisher<[Prescription], Never>
}


final class PrescriptionInteractor {

    // MARK: - Read only attributes
    private(set) var dataManager: DataManagerProtocol

    // MARK: - Private attributes
    /*@Published*/ private/*(set)*/ var prescriptions: [Prescription] = []
    private let subject = PassthroughSubject< [Prescription], Never>()
    private let currentPrescriptionIndexSubject = PassthroughSubject< Int, Never>()
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
             currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        }
    }

    func remove(prescription: Prescription) {
        dataManager.remove(prescription: prescription)
        currentPrescriptionIndex = 0
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
    }

    func getCurrentPrescriptionIndex()  -> AnyPublisher<Int, Never> {
        currentPrescriptionIndexSubject.send(currentPrescriptionIndex)
        return currentPrescriptionIndexSubject.eraseToAnyPublisher()
    }

    func getPrescriptions() -> AnyPublisher<[Prescription], Never> {
        self.dataManager.getPrescriptions()
            .sink { prescriptions in
                self.prescriptions = prescriptions
                self.subject.send(self.prescriptions)
            }.store(in: &cancellables)
        return subject.eraseToAnyPublisher()
    }
}
