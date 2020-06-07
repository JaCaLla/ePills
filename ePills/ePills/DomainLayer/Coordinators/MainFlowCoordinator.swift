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

protocol MainFlowCoordinatorProtocol {
    func start(dataManager: DataManagerProtocol)
}

class MainFlowCoordinator {

    // MARK: - Singleton handler
    static let shared = MainFlowCoordinator()

    // MARK: - Private attributes
    let firstPresciptionCoordinator = FirstPresciptionCoordinator()
    var dataManager: DataManagerProtocol = DataManager.shared
    private var onChangeRootVCSubscription = Set<AnyCancellable>()

    private init() { /*This prevents others from using the default '()' initializer for this class. */ }
}

extension MainFlowCoordinator: MainFlowCoordinatorProtocol {
    // MARK: - Pulic methods
    func start(dataManager: DataManagerProtocol) {
        self.dataManager = dataManager
        return self.presentTransactionsList()
    }

    // MARK: - Private/Internal
    private func presentTransactionsList() {

        guard let window = UIApplication.shared.keyWindowInConnectedScenes else { return }
        
        if dataManager.isEmpty() {
             window.rootViewController = firstPresciptionCoordinator.start()//TabBarController()
            firstPresciptionCoordinator.onFinishedPublisher.sink { vc in
                 window.rootViewController = TabBarController()//vc
             //   self.window = window
                 window.makeKeyAndVisible()
            }.store(in: &onChangeRootVCSubscription)
        } else {
            window.rootViewController = TabBarController()
        }
        window.makeKeyAndVisible()
    }
}
