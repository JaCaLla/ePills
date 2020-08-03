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
import Combine

public final class AppSetupCoordinator {

    // MARK: - Private/Internal
    var navitationController: UINavigationController = UINavigationController()
    private var cancellable = Set<AnyCancellable>()

    func start() -> UIViewController {
        let appSetupVM = AppSetupVM()
        appSetupVM.onToSSelectedPublisher.sink(receiveValue: {
            self.presentTermsOfUse()
        }).store(in: &cancellable)
        let appSetupView = AppSetupView(viewModel: appSetupVM)
        let appSetupVC = AppSetupVC(rootView: appSetupView)
        appSetupVC.title = R.string.localizable.setup_title.key.localized
        appSetupVC.tabBarItem = UITabBarItem(title: R.string.localizable.setup_title.key.localized,
                                             image: UIImage(systemName: "gear"),
                                             tag: 1)

        navitationController.viewControllers = [appSetupVC]
        return navitationController
    }

    func presentTermsOfUse() {
        let termsOfUseview = TermsOfUseView(viewmodel: TermsOfUseVM())
        let termsOfUseVC = TermsOfUseVC(rootView: termsOfUseview)
        termsOfUseVC.hidesBottomBarWhenPushed = true
        navitationController.pushViewController(termsOfUseVC, animated: true)
    }
}
