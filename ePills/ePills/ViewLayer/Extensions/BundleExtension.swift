//
//  BundleExtension.swift
//  ePills
//
//  Created by Javier Calatrava on 26/04/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation

extension Bundle {
    private static var bundle: Bundle!

    public static func localizedBundle() -> Bundle! {
        if bundle == nil {
            let appLang = UserDefaults.standard.string(forKey: "app_lang") ?? "en"
            guard let path = Bundle.main.path(forResource: appLang, ofType: "lproj") else { return Bundle()}
            bundle = Bundle(path: path)
        }

        return bundle
    }

    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "app_lang")
        guard let path = Bundle.main.path(forResource: lang, ofType: "lproj") else { return }
        bundle = Bundle(path: path)
    }

    var appName: String? {
        return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
}
