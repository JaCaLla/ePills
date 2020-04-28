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
    private var interactor: PrescriptionInteractor //= PrescriptionInteractor(dataManager: DataManager.shared)
    private var homeCoordinator: HomeCoordinator

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()
    @Published var prescriptions: [Prescription] = []

    init(interactor: PrescriptionInteractor,
         coordinator: HomeCoordinator) {
        self.interactor = interactor
        
        self.homeCoordinator = coordinator
        interactor.$prescriptions
            .assign(to: \.prescriptions, on: self)
            .store(in: &cancellables)
        print("HomePrescriptionVM \(self.interactor.prescriptions.count)")
    }
    
    func addPrescription() {
         self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor)
    }
//    func set(view: HomePrescriptionView) {
//        self.view = view
//        self.view?.onAddPrescriptionPublisher.sink {
//            self.homeCoordinator.presentPrescriptionForm(interactor: self.interactor)
//        }.store(in: &cancellables)
//    }
}


extension HomePrescriptionVM: HomePrescriptionVMProtocol {

}
