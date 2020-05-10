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
    var onFinishedPublisher: AnyPublisher<Void, Never> {
        return onUIViewControllerInternalPublisher.eraseToAnyPublisher()
    }
    private var onUIViewControllerInternalPublisher = PassthroughSubject<Void, Never>()

    // MARK: - Subscriptions
    private var onDismissIssueSubscription = Set<AnyCancellable>()
    private var onAddFirstSubscription = Set<AnyCancellable>()

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()

    // MARK: - Public Helpers
    func start(navigationController: Bool = true, prescriptionInteractor: PrescriptionInteractorProtocol? = nil) -> UIViewController {
        let homeView = FirstPrescriptionView( coordinator: self)
        let firstPrescriptionVC = FirstPrescriptionVC(rootView: homeView)
        homeView.onAddFirstPrescriptionPublisher.sink {
            self.presentPrescriptionForm(homeView: homeView,
                                         prescriptionInteractor: prescriptionInteractor ?? PrescriptionInteractor(dataManager: DataManager.shared) )
        }.store(in: &onAddFirstSubscription)
        firstPrescriptionVC.tabBarItem = UITabBarItem(title: R.string.localizable.home_title.key.localized,
        image: UIImage(systemName: "plus.rectangle"),
        tag: 0)
        guard navigationController else {
            return firstPrescriptionVC
        }
        navitationController.viewControllers = [firstPrescriptionVC];
        return navitationController
    }

    // MARK: - Private/Internal
    fileprivate func presentPrescriptionForm(homeView: FirstPrescriptionView,
                                             prescriptionInteractor: PrescriptionInteractorProtocol) {
        let prescriptionFormVM = PrescriptionFormVM(interactor: prescriptionInteractor, prescription: nil)
        prescriptionFormVM.onDismissPublisher.sink {
                        self.onUIViewControllerInternalPublisher.send()
        }.store(in: &onDismissIssueSubscription)
        let prescriptionFormView = PrescriptionFormView(viewModel: prescriptionFormVM)
        let prescriptionFormVC = PrescriptionFormVC(rootView: prescriptionFormView)
       
        prescriptionFormVC.hidesBottomBarWhenPushed = true
        self.navitationController.pushViewController(prescriptionFormVC, animated: true)
    }
}
