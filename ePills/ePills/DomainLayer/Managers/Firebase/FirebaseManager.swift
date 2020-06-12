//
//  FirebaseManager.swift
//  Vueling
//
//  Created by Javier Calatrava on 18/03/2020.
//  Copyright © 2020 Vueling. All rights reserved.
//

import Firebase
import Foundation

class FirebaseManager: NSObject {

    static let shared = FirebaseManager()

    // MARK: - Lifecycle
    fileprivate override init() {
        let firebasePlistFileName = AppEnvironment.shared.environment.firebaseConfigFilename
        let filePath = Bundle.main.path(forResource: firebasePlistFileName, ofType: "plist") ?? ""
        guard let fileopts = FirebaseOptions(contentsOfFile: filePath) else {
            print("Couldn't load config file")
            return
        }
        FirebaseApp.configure(options: fileopts)
        Analytics.setAnalyticsCollectionEnabled(true)
    }

    @objc func configure() {
        // Created empty function for avoiding lint warning
    }
}

extension FirebaseManager: AnalyticsEngineProtocol {
    func logScreen(name: String, flow: String?) {
        Analytics.setScreenName(name, screenClass: flow)
    }
    
    func logEvent(name: String, metadata: [String: Any]) {
        Analytics.logEvent(name, parameters: metadata)
    }
    
    func setUser(property: String, value: String? ) {
        Analytics.setUserProperty(value, forName: property)
    }
}
