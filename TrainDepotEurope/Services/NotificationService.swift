//
//  NotificationService.swift
//  TrainDepotEurope
//
//  Created on November 4, 2025
//

import Foundation
import UserNotifications
import Combine

class NotificationService: ObservableObject {
    static let shared = NotificationService()
    
    @Published var areNotificationsEnabled = false
    
    private init() {}
    
    func requestPermissions() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.areNotificationsEnabled = granted
            }
            
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func sendNotification(title: String, body: String, delay: TimeInterval = 0.1) {
        guard areNotificationsEnabled else { return }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
}

