//
//  TabBarController.swift
//  ePills
//
//  Created by Javier Calatrava on 22/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    var homeCoordinator:HomeCoordinator = HomeCoordinator()
    let homeNavigationController: UINavigationController = UINavigationController()
     let interactor = PrescriptionInteractor(dataManager: DataManager.shared)

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.setupView()
    }
    
    init(/*coordinator:HomeCoordinator*/) {
        
//        self.homeCoordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {

      
        print("Tab:\(interactor.prescriptions.count)")
        let homePrescriptionVM = HomePrescriptionVM(interactor: PrescriptionInteractor(dataManager: DataManager.shared), coordinator: self.homeCoordinator)
        let homePrescriptionView = HomePrescriptionView(viewModel: homePrescriptionVM)
        let homeVC = HomePrescriptionVC(rootView: homePrescriptionView)//HomePrescriptionVC(rootView: prescriptionFormView)
        homeVC.title = "_Home"
        homeVC.view.backgroundColor = UIColor.blue
        homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .downloads, tag: 0)

        homeNavigationController.viewControllers = [homeVC]
//
        let setupVC = UIViewController()
        setupVC.title = "_Setup"
        setupVC.view.backgroundColor = UIColor.orange
        setupVC.tabBarItem = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
       // self.homeCoordinator = HomeCoordinator()
        let controllers = [homeCoordinator.start(),
                           setupVC]
        self.viewControllers = controllers//.map { UINavigationController(rootViewController: $0)}
       
    }

}
