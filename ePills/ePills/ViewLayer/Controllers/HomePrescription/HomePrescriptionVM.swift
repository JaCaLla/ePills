//
//  HomePrescriptionVM.swift
//  ePills
//
//  Created by Javier Calatrava on 27/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine

protocol HomePrescriptionVMProtocol {
    func addPrescription()
    func remove(prescription: Prescription)
    func update(prescription: Prescription)
}

public final class HomePrescriptionVM: ObservableObject {

    // MARK: - Public attributes
    private var view: HomePrescriptionView?

    // MARK: - Private attributes
    private var interactor: PrescriptionInteractorProtocol
    private var homeCoordinator: HomeCoordinatorProtocol

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var prescriptions: [Prescription] = []
    @Published var dosePrescription: Prescription? {
        didSet {
            print("todo")
        }
    }
    @Published var currentPage = 0
    @Published var currentPrescription: Prescription = Prescription(name: "", unitsBox: 0, interval: Interval(hours: 0, label: ""), unitsDose: 0)
    @Published var onEditing: Prescription?

    init(interactor: PrescriptionInteractorProtocol = PrescriptionInteractor(),
         homeCoordinator: HomeCoordinatorProtocol) {
        self.interactor = interactor
        self.homeCoordinator = homeCoordinator

        self.interactor.getPrescriptions()
            .sink{ prescriptions in
                self.prescriptions = prescriptions
        }.store(in: &cancellables)
        self.interactor.getCurrentPrescriptionIndex()
            .sink { currentPrescriptionIndex in
                self.currentPage = currentPrescriptionIndex
        }.store(in: &cancellables)
        self.$prescriptions
            .sink { someValue in
                guard someValue.isEmpty else { return }
                self.homeCoordinator.replaceByFirstPrescription(interactor: self.interactor)
            }.store(in: &cancellables)
        self.$onEditing
                  .sink { prescription in
                      guard let uwpPrescription = prescription else { return }
                    self.update(prescription: uwpPrescription)
                  }.store(in: &cancellables)
    }
}


extension HomePrescriptionVM: HomePrescriptionVMProtocol {
    func addPrescription() {
        self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor,
                                                     prescription: nil)
    }

    func remove(prescription: Prescription) {
        self.interactor.remove(prescription: prescription)
        self.currentPage = 0
    }
    
    func update(prescription: Prescription) {
        self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor,
                                                     prescription: prescription)
    }
}
