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
}

public final class HomePrescriptionVM: ObservableObject {

    // MARK: - Public attributes
    private var view: HomePrescriptionView?

    // MARK: - Private attributes
    private var interactor: PrescriptionInteractor
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

    init(interactor: PrescriptionInteractor = PrescriptionInteractor(),
         homeCoordinator: HomeCoordinatorProtocol) {
        self.interactor = interactor
        self.homeCoordinator = homeCoordinator
        interactor.$prescriptions
            .assign(to: \.prescriptions, on: self)
            .store(in: &cancellables)
        self.$prescriptions
            .sink { someValue in
                //guard someValue.isEmpty else { return }
                if someValue.isEmpty {
                    self.homeCoordinator.replaceByFirstPrescription(interactor: self.interactor)
                } else {
                    self.currentPage = self.interactor.getCurrentPrescriptionIndex()
                }
            }.store(in: &cancellables)
    }
}


extension HomePrescriptionVM: HomePrescriptionVMProtocol {
    func addPrescription() {
        self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor)
    }

    func remove(prescription: Prescription) {
        self.interactor.remove(prescription: prescription)
        self.currentPage = 0
    }
}
