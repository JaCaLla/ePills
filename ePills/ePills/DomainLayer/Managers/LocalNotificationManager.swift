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
    func addNotification(prescription: Prescription, onComplete: @escaping ((Bool) -> Void))
    func removeNotification(prescription: Prescription)
}

public final class LocalNotificationManager: NSObject {
    static let shared:LocalNotificationManager = LocalNotificationManager()
    
//    override init() {
//
//    }
}


extension LocalNotificationManager : LocalNotificationManagerProtocol {
//
//    func set(delegate: UNUserNotificationCenterDelegate) {
//        UNUserNotificationCenter.current().delegate = delegate
//    }
    
    func requestAuthorization(onComplete:  @escaping (() -> Void)) {
        UNUserNotificationCenter.current().delegate = self
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(
        options: [.badge, .sound, .alert]) {
        [weak center, weak self] granted, _ in
//        guard granted, let center = center, let self = self
//        else { return }
            onComplete()
            
            
        // Take action here
      }
    }
    
    func removeNotification(prescription: Prescription) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [prescription.id.uuidString])
    }
    
    func addNotification(prescription: Prescription, onComplete: @escaping ((Bool) -> Void)) {
        guard !prescription.isLast() else { return }
        
        let date = Date(timeIntervalSinceNow: TimeInterval(prescription.interval.secs - Prescription.Constants.ongoingReadyOffset))
        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(prescription.interval.secs),
//                                                        repeats: false)
        let content = UNMutableNotificationContent()
        
        content.title = "\(R.string.localizable.app_name.key.localized). \(prescription.name)"
        content.subtitle = "\(R.string.localizable.notification_next_dose.key.localized): \(Date().format("HH:MM"))"
//        content.badge = 1
        content.categoryIdentifier = R.string.localizable.app_name.key.localized
//        content.userInfo = [
//          "title": "Family Reunion",
//          "start": "2018-04-10T08:00:00-08:00",
//          "end": "2018-04-10T12:00:00-08:00",
//          "id": 12
//        ]
        content.sound = UNNotificationSound.default
        
        let identifier = prescription.id.uuidString//UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
         //   guard let completion = onComplete else  { return }
          if let error = error {
            // Handle unfortunate error if one occurs.
            print("\(error)")

          }
          //  onComplete(error == nil)
           
            UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in
                
                notifications.forEach {
                    print("\($0)")
                }
                
                
            }
        }
        
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

   // refreshNotificationList()

    completionHandler([.alert, .sound, .badge])
  }
}
extension LocalNotificationManager : Resetable {
    func reset() {

        UNUserNotificationCenter.current().delegate = nil

        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
