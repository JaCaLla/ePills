//
//  AppConfigurationVC.swift
//  ePills
//
//  Created by Javier Calatrava on 24/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

enum Environment: String {
    case debug = "Debug"
    case production = "Release"
    case unknown = "Unknown"

    var firebaseConfigFilename: String {
        switch self {
        case .debug: return R.file.googleServiceInfoDebugPlist.name
        case .production: return R.file.googleServiceInfoProdPlist.name
        default: return ""
        }
    }
    
    var appGroup: String {
        switch self {
        case .debug: return "group.com.JCa.ePills.debug"
        case .production: return "group.com.JCa.ePills.debug"
        default: return ""
        }
    }

    var toString: String {
        switch self {
        case .debug: return "dev"
        case .production: return "production"
        default: return ""
        }
    }
}

class AppEnvironment {

    static let shared =  AppEnvironment()

    private init() { /*This prevents others from using the default '()' initializer for this class. */ }

    lazy var environment: Environment = {
        if let configuration = Bundle.main.infoDictionary?["Configuration"] as? String {
            guard let environment = Environment(rawValue:configuration) else {
                print("No Environment")
                return Environment.unknown
            }
            return environment
        }
        print("No Environment")
        return Environment.unknown

    }()

    func getPlistdictionary() -> NSDictionary? {

        var plistDict: NSDictionary = NSDictionary()
        if let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let plistDictFetched = NSDictionary(contentsOfFile: path) {
            plistDict = plistDictFetched
        }

        return plistDict
    }

}
