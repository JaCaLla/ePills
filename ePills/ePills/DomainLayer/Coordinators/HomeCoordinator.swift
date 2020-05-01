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

protocol HomeCoordinatorProtocol {
    func presentPrescriptionForm(interactor: PrescriptionInteractorProtocol)
    func replaceByFirstPrescription(interactor: PrescriptionInteractorProtocol)
}

public final class HomeCoordinator {

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()
    private var cancellable = Set<AnyCancellable>()

    private var onDismissIssueSubscription = Set<AnyCancellable>()

    func start() -> UIViewController {
        

        navitationController.viewControllers = [getHomePrescriptionVC()]
        return navitationController
    }

    func getHomePrescriptionVC() -> UIViewController {
        let homePrescriptionVM = HomePrescriptionVM(homeCoordinator: self)
        let homePrescriptionView = HomePrescriptionView(viewModel: homePrescriptionVM)
        let homePrescriptionVC = HomePrescriptionVC(rootView: homePrescriptionView)
        homePrescriptionVC.title = "_Home2"
        homePrescriptionVC.tabBarItem = UITabBarItem(title: "_Home13",
                                                     image: UIImage(systemName: "plus.rectangle"),
                                                     tag: 0)
        return homePrescriptionVC
    }

}

extension HomeCoordinator: HomeCoordinatorProtocol {
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

    func replaceByFirstPrescription(interactor: PrescriptionInteractorProtocol) {
        let firstPresciptionCoordinator = FirstPresciptionCoordinator()
        firstPresciptionCoordinator.navitationController = self.navitationController
        let previousViewControllers = self.navitationController.viewControllers
        firstPresciptionCoordinator.onFinishedPublisher.sink { _ in
            self.navitationController.viewControllers = [self.getHomePrescriptionVC()]
        }.store(in: &cancellable)
        let rootViewController = firstPresciptionCoordinator.start(navigationController: false)
        rootViewController.modalTransitionStyle = .crossDissolve
        self.navitationController.viewControllers = [rootViewController]

//         self.navitationController.viewControllers = [UIViewController()]
    }
}
