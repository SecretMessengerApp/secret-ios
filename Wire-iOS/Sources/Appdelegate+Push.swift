//
// Secret
// Appdelegate+Push.swift
//
// Created by 王杰 on 2020/9/25.
//



import Foundation
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       willPresent notification: UNNotification,
                                       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        Logging.push.safePublic("Appdelegate Notification center wants to present in-app notification: \(notification)")
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter,
                                       didReceive response: UNNotificationResponse,
                                       withCompletionHandler completionHandler: @escaping () -> Void)
    {
        
        Logging.push.safePublic("Appdelegate Did receive notification response: \(response)")
    }
    
}
