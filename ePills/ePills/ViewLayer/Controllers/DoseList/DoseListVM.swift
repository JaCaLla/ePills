//
//  DoseListVM.swift
//  ePills
//
//  Created by Javier Calatrava on 02/06/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import Combine
import UIKit


public final class DoseListVM: ObservableObject {

    // MARK: - Publishers
    private var cancellables = Set<AnyCancellable>()

    // MARK: Private attributes
    private var medicine: Medicine
    private var interactor: MedicineInteractorProtocol
    private var timeManager: TimeManagerProtocol

    // MARK: - Constructor
    init(medicine: Medicine,
         interactor: MedicineInteractorProtocol = MedicineInteractor(),
         timeManager: TimeManagerProtocol = TimeManager()) {
        self.medicine = medicine
        self.timeManager = timeManager
        self.interactor = interactor
    }
}
