//
//  TabBarController.swift
//  ePills
//
//  Created by Javier Calatrava on 22/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    let coordinator:HomeCoordinator

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    init(coordinator:HomeCoordinator) {
        
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
     
        let homePrescriptionView = HomePrescriptionView(coordinator: self.coordinator)
        let homeVC = HomePrescriptionVC(rootView: homePrescriptionView)//HomePrescriptionVC(rootView: prescriptionFormView)
        homeVC.title = "_Home"
        homeVC.view.backgroundColor = UIColor.blue
        homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 0)
        let setupVC = UIViewController()
        setupVC.title = "_Setup"
        setupVC.view.backgroundColor = UIColor.orange
        setupVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        
        let controllers = [homeVC, setupVC]
        self.viewControllers = controllers.map { UINavigationController(rootViewController: $0)}
       
    }

}
