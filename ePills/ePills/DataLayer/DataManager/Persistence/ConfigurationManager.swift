//
//  ConfigurationManager.swift
//  iMug
//
//  Copyright © 2017 Nestlé S.A. All rights reserved.
//
import Foundation

class ConfigurationManager {

    static let shared = ConfigurationManager()

    struct UserDefaultsKeys {
        static let appName = "appName"
        static let appConfig = "appConfig"
        static let version = "version"
        static let defaultMachineFirmware = "defaultMachineFirmware"
        static let localNotificationSettings = "localNotificationsSettings"
        static let remotePushNotificationSettings = "remotePushNotificationSettings"
        static let localizationSettings = "localizationSettings"
        static let pushNotificationTokenSentToBE = "pushNotificationTokenSentToBE"
        static let country = "country"
        static let didUserRejectLogin = "didUserRejectLogin"
        static let sessionExpiration = "sessionExpiration"
        static let sessionToken = "sessionToken"
        static let sessionExpirationDate = "sessionExpirationDate"
        static let isLongSessionRenovable = "isLongSessionRenovable"
        static let sessionAccountSettings = "sessionAccountSettings"
        static let isFirstAppExecution = "isFirstAppExecution"
        static let archivedChats = "archivedChats"
        static let reviewedChats = "reviewedChats"
        static let isGameEnabledByUser = "gameEnabledByUser"
        static let isAlarmEnabledByUser = "alarmEnabledByUser"
        static let gameInfoScreenPresented = "gameInfoScreenPresented"
        static let installationTimeStamp = "installationTimeStamp"
        static let userDefaultDomainName = "notificationserviceExtension"
        static let userDefaultBadgeNumber = "userDefaultBadgeNumber"
        static let appReviewedByUser = "appReviewedByUser"
        static let appReviewRequestedByHost = "appReviewRequestedByHost"
        static let actionRequestedByHost = "actionRequestedByHost"
        static let actionRecipeRequestedByHost = "actionRecipeRequestedByHost"
        static let actionDeeplinkRequestedByHost = "actionDeeplinkRequestedByHost"
        static let firstAppExecutionTimestamp = "firstAppExecutionTimestamp"
        static let machinePairedOnce = "machinePairedOnce"
        static let allowedTagUserWithCustomRecipes = "allowedTagUserWithCustomRecipes"
        static let allowedTagPairedDevice = "allowedTagPairedDevice"
        static let allowedTagRateAppShown = "allowedTagRateAppShown"
        static let jsonStrSeasonRecipes = "jsonStrDefaultRecipes"
        static let rateAppShowndOnce = "RateAppShowndOnce"
        static let recipesBrewedOnce = "recipesBrewedOnce"
    }

    private init() { /*This prevents others from using the default '()' initializer for this class. */ }

    func reset() {
        for key in Array(UserDefaults.standard.dictionaryRepresentation().keys) {
            UserDefaults.standard.removeObject(forKey: key)
        }
        UserDefaults.standard.synchronize()
    }

    func getAppName() -> String {
        guard let name = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return ""
        }
        return name
    }

    func getAppVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return ""
        }
        return version
    }

    // MARK: - Version
    func setLastExecutedToBundleVersion() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        UserDefaults.standard.set(version, forKey: UserDefaultsKeys.version)
        UserDefaults.standard.synchronize()
    }

    func getLastExecutedVersion() -> String? {
        if let version = UserDefaults.standard.object(forKey: UserDefaultsKeys.version) as? String {
            return version
        }
        return nil
    }

    func isFirstTimeInLifeAppExecution() -> Bool {
        return self.getLastExecutedVersion() == nil
    }

    func isFirstTimeAfterSoftwareUpdateExecution() -> Bool {
        if let uwpCurrentVersion = self.getLastExecutedVersion() {
            return uwpCurrentVersion.compare(self.getAppVersion(), options: .numeric) == .orderedDescending
        } else {
            return true
        }
    }
}
