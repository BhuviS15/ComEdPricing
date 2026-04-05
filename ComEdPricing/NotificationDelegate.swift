//
//  NotificationDelegate.swift
//  ComEdPricing
//
//  Created by Bhuvi Singh on 2/1/26.
//

import Foundation
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Singleton instance to be used across the app
    static let shared = NotificationDelegate()
    
    // MARK: - Foreground Notification Handling
    // This method is called when a notification arrives while the app is in the FOREGROUND.
    // We return [.banner, .sound] so the user still sees the alert even if they are looking at the app.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
