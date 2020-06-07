//
//  TabBarController.swift
//  ePills
//
//  Created by Javier Calatrava on 22/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {

    var homeCoordinator: HomeCoordinator = HomeCoordinator()
    var appConfigurationCoordinator: AppConfigurationCoordinator = AppConfigurationCoordinator()
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupView()
    }

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {

           self.viewControllers = [homeCoordinator.start(),
                                appConfigurationCoordinator.start()]

    }

}
