//
//  LocalNotificationManager.swift
//  ePills
//
//  Created by Javier Calatrava on 07/05/2020.
//  Copyright © 2020 Javier Calatrava. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

protocol LocalNotificationManagerProtocol {
    func requestAuthorization(onComplete: @escaping (() -> Void))
    func addNotification(medicine: Medicine, onComplete: @escaping ((Bool) -> Void))
    func removeNotification(medicine: Medicine)
}

public final class LocalNotificationManager: NSObject {
    static let shared: LocalNotificationManager = LocalNotificationManager()
}

extension LocalNotificationManager: LocalNotificationManagerProtocol {

    func requestAuthorization(onComplete: @escaping (() -> Void)) {
        UNUserNotificationCenter.current().delegate = self
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(
            options: [.badge, .sound, .alert]) {
            [weak center, weak self] granted, _ in
            onComplete()
        }
    }

    func removeNotification(medicine: Medicine) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [medicine.id])
    }

    func addNotification(medicine: Medicine, onComplete: @escaping ((Bool) -> Void)) {
        guard !medicine.isLast() else { return }

        let date = Date(timeIntervalSinceNow: TimeInterval(medicine.intervalSecs - Cycle.Constants.ongoingReadyOffset))
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let content = UNMutableNotificationContent()

        content.title = "\(R.string.localizable.app_name.key.localized). \(medicine.name)"
        content.subtitle = "\(R.string.localizable.notification_next_dose.key.localized)\(Date(timeIntervalSince1970: Date().timeIntervalSince1970 + Double(medicine.intervalSecs)).format("HH:mm"))"
        content.categoryIdentifier = R.string.localizable.app_name.key.localized

        content.sound = UNNotificationSound.default

        let identifier = medicine.id//UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("\(error)")

            }

            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

                notifications.forEach {
                    print("\($0)")
                }
            }
        }

    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
}
extension LocalNotificationManager: Resetable {
    func reset() {
        UNUserNotificationCenter.current().delegate = nil
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
