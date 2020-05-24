//
//  AppConfigurationCoordinator.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI

public final class AppConfigurationCoordinator {

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()

    func start() -> UIViewController {
        let appSetupVM = AppSetupVM()
        let appSetupView = AppSetupView(viewModel: appSetupVM)
        let appSetupVC = AppSetupVC(rootView: appSetupView)
        appSetupVC.title = "_Setup"
        appSetupVC.view.backgroundColor = UIColor.orange
        appSetupVC.tabBarItem = UITabBarItem(title: R.string.localizable.setup_title.key.localized,
                                                     image: UIImage(systemName: "gear"),
                                                     tag: 1)

        navitationController.viewControllers = [appSetupVC]
        return navitationController
    }

//    func getHomePrescriptionVC(interactor: PrescriptionInteractorProtocol) -> UIViewController {
//        let appConfigurationView = AppConfigurationView()
//        let appConfigurationVC = AppConfigurationVC(rootView: appConfigurationView)
////        let homePrescriptionVM = HomePrescriptionVM(interactor: interactor, homeCoordinator: self)
////        let homePrescriptionView = HomePrescriptionView(viewModel: homePrescriptionVM)
////        let homePrescriptionVC = HomePrescriptionVC(rootView: homePrescriptionView)
////       // homePrescriptionVC.title = "_Home2"
////        homePrescriptionVC.tabBarItem = UITabBarItem(title: R.string.localizable.home_title.key.localized,
////                                                     image: UIImage(systemName: "plus.rectangle"),
////                                                     tag: 0)
//        return appConfigurationVC
//    }

}
