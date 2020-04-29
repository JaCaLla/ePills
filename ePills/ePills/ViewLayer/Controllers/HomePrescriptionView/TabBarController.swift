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

        let setupVC = UIViewController()
        setupVC.title = "_Setup"
        setupVC.view.backgroundColor = UIColor.orange
        setupVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)

        self.viewControllers = [homeCoordinator.start(),
            setupVC]

    }

}
