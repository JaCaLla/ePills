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
            let path = Bundle.main.path(forResource: appLang, ofType: "lproj")
            bundle = Bundle(path: path!)
        }

        return bundle;
    }

    public static func setLanguage(lang: String) {
        UserDefaults.standard.set(lang, forKey: "app_lang")
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        bundle = Bundle(path: path!)
    }
    

        var appName: String? {
            return object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        }
}
