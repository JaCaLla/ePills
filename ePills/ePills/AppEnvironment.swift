//
//  AppConfig.swift
//  iMug
//
//  Copyright © 2017 Nestlé S.A. All rights reserved.
//

import Foundation
//import UIKit
//import blenescafelegacy
//import CocoaLumberjack

enum Environment: String {
    case debug = "Debug"
    case production = "Release"
    case unknown = "Unknown"

//    struct ConstantsBaseURL {
//
//        static let debug        = "dev-api.aws.imugapp.nescafe.com"
//        static let staging      = "stage-api.aws.imugapp.nescafe.com"
//        static let production   = "api.aws.imugapp.nescafe.com"
//        static let unknown      = ""
//    }

//    var gameUrlStr:String {
//        switch self {
//        case .debug, .staging: return  AppConstants.https + "www.infarmershoes.com/stage/"
//        case .production: return  AppConstants.https + "www.infarmershoes.com/"
//        default: return ""
//        }
//    }
//
//    var baseURL: String {
//        switch self {
//        case .debug: return ConstantsBaseURL.debug
//        case .staging: return ConstantsBaseURL.staging
//        case .production: return ConstantsBaseURL.production
//        default : return ConstantsBaseURL.unknown
//        }
//    }
//
//    var tokenGoogleTag: String {
//        switch self {
//        case .debug : return "DE"
//        case .staging: return "STA"
//        case .production: return "PRO"
//        default: return ""
//        }
//    }
//
//    var analyticsTimmingTokenId: String {
//        switch self {
//        case .debug : return "UA-43230251-3"
//        case .staging, .production: return "UA-94050708-3"
//        default: return ""
//        }
//    }
//
//    var jsonCountryFilename: String? {
//        switch self {
//        case .debug :       return "countries_debug"
//        case .staging:      return "countries_staging"
//        case .production:   return "countries_production"
//        default: return nil
//        }
//    }
//
//    func googleSignInClientID() -> String {
//
//        var clientId = ""
//        let plist = AppEnvironment.shared.getPlistdictionary()
//
//        if let uwpClientId = plist?["GoogleClientID"] as? String {
//            clientId = uwpClientId
//        }
//
//        return clientId
//    }
//
//    var hockeyId: String {
//        switch self {
//        case .debug: return "6f738ca06634445b8fab4a94290a087d"
//        case .staging: return "d2135850d1e24e60ad39a291775a15de"
//        case .production: return "65fefedc900148cc8563503d11be0120"
//        default: return ""
//        }
//    }
//
//    var urlAppStore: String {
//        return AppConstants.urlStore
//    }
//
//    // MARK: - IoT Tama SDK
//    var enableIotCommunication:Bool {
//        switch self {
//        case .debug:                    return false
//        case .staging,.production:      return true
//        default: return true
//        }
//    }

//    var firebaseConfigFilename: String {
//        switch self {
//        case .debug: return R.file.googleServiceInfoDEBUGPlist.name
//        case .staging: return R.file.googleServiceInfoStagingPlist.name
//        case .production: return R.file.googleServiceReleaseInfoPlist.name
//        default: return ""
//        }
//    }

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
