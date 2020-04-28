//
//  HomeCoordinator.swift
//  ePills
//
//  Created by Javier Calatrava on 27/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

import Foundation
import UIKit
import SwiftUI
import Combine

public final class HomeCoordinator {

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()
    
     private var onDismissIssueSubscription = Set<AnyCancellable>()

    func start() -> UIViewController {
        let interactor = PrescriptionInteractor(dataManager: DataManager.shared)
        let homePrescriptionVM = HomePrescriptionVM(interactor: interactor, coordinator: self)
        let homePrescriptionView = HomePrescriptionView(viewModel: homePrescriptionVM)
        let homePrescriptionVC = HomePrescriptionVC(rootView: homePrescriptionView)
        homePrescriptionVC.title = "_Home"
        homePrescriptionVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 0)

        navitationController.viewControllers = [homePrescriptionVC]
        return navitationController
    }
    
     func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol) {
        let prescriptionFormVM = PrescriptionFormVM(interactor: interactor)
        prescriptionFormVM.onDismissPublisher.sink {
            self.navitationController.popViewController(animated: true)
        }.store(in: &onDismissIssueSubscription)
        let prescriptionFormView = PrescriptionFormView(viewModel: prescriptionFormVM)
        let prescriptionFormVC = PrescriptionFormVC(rootView: prescriptionFormView)
        prescriptionFormVC.hidesBottomBarWhenPushed = true

        self.navitationController.pushViewController(prescriptionFormVC, animated: true)
    }
}
