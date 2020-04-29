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

}

public final class HomePrescriptionVM: ObservableObject {

    // MARK: - Public attributes
    private var view: HomePrescriptionView?

    // MARK: - Private attributes
    private var interactor: PrescriptionInteractor
    private var homeCoordinator: HomeCoordinator

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var prescriptions: [Prescription] = []
    @Published var dosePrescription: Prescription? {
        didSet {
            print("todo")
        }
    }

    init(interactor: PrescriptionInteractor = PrescriptionInteractor(),
         homeCoordinator: HomeCoordinator) {
        self.interactor = interactor
        self.homeCoordinator = homeCoordinator
        interactor.$prescriptions
            .assign(to: \.prescriptions, on: self)
            .store(in: &cancellables)
    }
    
    func addPrescription() {
         self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor)
    }
}


extension HomePrescriptionVM: HomePrescriptionVMProtocol {

}
