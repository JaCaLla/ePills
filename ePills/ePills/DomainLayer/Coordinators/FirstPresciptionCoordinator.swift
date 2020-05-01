//
//  HomeCoorindator.swift
//  ePills
//
//  Created by Javier Calatrava on 21/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine

final public class FirstPresciptionCoordinator {

    // MARK: - Publishers
    var onFinishedPublisher: AnyPublisher<UIViewController, Never> {
        return onUIViewControllerInternalPublisher.eraseToAnyPublisher()
    }
    private var onUIViewControllerInternalPublisher = PassthroughSubject<UIViewController, Never>()

    // MARK: - Subscriptions
    private var onDismissIssueSubscription = Set<AnyCancellable>()
    private var onAddFirstSubscription = Set<AnyCancellable>()

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()

    // MARK: - Public Helpers
    func start(navigationController: Bool = true) -> UIViewController {
        let homeView = FirstPrescriptionView( coordinator: self)
        let firstPrescriptionVC = FirstPrescriptionVC(rootView: homeView)
        homeView.onAddFirstPrescriptionPublisher.sink {
            self.presentPrescriptionForm(homeView: homeView)
        }.store(in: &onAddFirstSubscription)
        guard navigationController else {
            return firstPrescriptionVC
        }
        navitationController.viewControllers = [firstPrescriptionVC];
        return navitationController
    }

    // MARK: - Private/Internal
    fileprivate func presentPrescriptionForm(homeView: FirstPrescriptionView) {
        let prescriptionFormVM = PrescriptionFormVM(interactor: PrescriptionInteractor(dataManager: DataManager.shared))
        prescriptionFormVM.onDismissPublisher.sink {
                        let tabBarC = TabBarController()
                        self.onUIViewControllerInternalPublisher.send(tabBarC)
        }.store(in: &onDismissIssueSubscription)
        let prescriptionFormView = PrescriptionFormView(viewModel: prescriptionFormVM)
        let prescriptionFormVC = PrescriptionFormVC(rootView: prescriptionFormView)
       
        prescriptionFormVC.hidesBottomBarWhenPushed = true
        self.navitationController.pushViewController(prescriptionFormVC, animated: true)
    }
}
