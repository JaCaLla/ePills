//
//  MainFlowCoordinator.swift
//  vlng
//
//  Created by Javier Calatrava Llaveria on 21/05/2019.
//  Copyright © 2019 Javier Calatrava Llaveria. All rights reserved.
//

import Foundation
import UIKit
import Combine
import SwiftUI

class MainFlowCoordinator {

    // MARK: - Singleton handler
    static let shared = MainFlowCoordinator()

    // MARK: - Private attributes
//    private let navigationController = UINavigationController()
//    private var onGetIssueSubscription = Set<AnyCancellable>()
//    private var onDismissIssueSubscription = Set<AnyCancellable>()
    let firstPresciptionCoordinator = FirstPresciptionCoordinator()
    
    private var onChangeRootVCSubscription = Set<AnyCancellable>()

    private init() { /*This prevents others from using the default '()' initializer for this class. */ }

    // MARK: - Pulic methods
    func start() {
        return self.presentTransactionsList()
    }

    // MARK: - Private/Internal
    private func presentTransactionsList() {
/*
        let routesVC = RoutesVC.instantiate()
        routesVC.onGetIssueInternalPublisher.sink { issue in
            self.presentIssue(issue: issue)
        }.store(in: &onGetIssueSubscription)
        routesVC.modalTransitionStyle = .crossDissolve
        guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }
        navigationController.viewControllers = [routesVC]
        window.rootViewController = navigationController
 */
        guard let window = UIApplication.shared.keyWindowInConnectedScenes else {
            return
            
        }
        window.rootViewController = firstPresciptionCoordinator.start()//TabBarController()
        
        firstPresciptionCoordinator.onFinishedPublisher.sink { vc in
             window.rootViewController = TabBarController()//vc
         //   self.window = window
             window.makeKeyAndVisible()
        }.store(in: &onChangeRootVCSubscription)
        
       // self.window = window
        window.makeKeyAndVisible()
        
    }
}
