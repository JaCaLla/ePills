//
//  AppDelegate.swift
//  seco
//
//  Created by Javier Calatrava on 20/02/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        StartUpAppSequencer().start()
        return true
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 88
    }
}

