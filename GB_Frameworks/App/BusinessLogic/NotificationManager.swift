//
//  NotificationManager.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 06.06.2022.
//

import UIKit
import UserNotifications
import CoreLocation

class NotificationManager: NSObject {
    static let instance = NotificationManager()

    private let center = UNUserNotificationCenter.current()
    private weak var locationManager = LocationManager.instance
    
    private override init() {
        super.init()
        configureManager()
    }
    
    func requestAutorization(options: UNAuthorizationOptions) {
        center.requestAuthorization(options: options) { granted, error in
            if granted {
                print("Разрешение получено")
            } else {
                print("Разрешение не получено")
                print(error?.localizedDescription ?? "Ошибок нет")
            }
        }
    }
    
    func sendNotificationRequest(content: UNNotificationContent,
                                 trigger: UNNotificationTrigger,
                                 identifier: String = UUID().uuidString) {
        checkPermission()
        
        let request = UNNotificationRequest(identifier: identifier,
                                            content: content,
                                            trigger: trigger)
        self.center.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func makeNotificationContent(title: String, subtitle: String,
                                 body: String, badge: NSNumber) -> UNNotificationContent {
        
        let content = UNMutableNotificationContent()
        
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.badge = badge
        content.sound = .default
        content.categoryIdentifier = "User Actions"
        
        return content
    }
    
    func clearNotificationBage() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    private func checkPermission() {
        center.getNotificationSettings() { settings in
            guard
                (settings.authorizationStatus == .authorized) ||
                    (settings.authorizationStatus == .provisional)
            else {
                print("Нет разрешения на отправку уведомлений")
                return
            }
        }
    }
}

// MARK: - Triggers
extension NotificationManager {
    func makeIntervalNotificatioTrigger(timeInterval: TimeInterval,
                                        repeats: Bool) -> UNNotificationTrigger {
        UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: repeats)
    }
    
    func makeCalendarNotificationTrigger(repeatSettings: Set<Calendar.Component>) -> UNNotificationTrigger {
        let date = Date(timeIntervalSinceNow: 3600)
        let triggerSettings = Calendar.current.dateComponents(repeatSettings, from: date)
        return UNCalendarNotificationTrigger(dateMatching: triggerSettings, repeats: true)
    }
    
    func makeExactTimeNotificationTrigger(day: Int, hour: Int, minute: Int) -> UNNotificationTrigger {
        var dateInfo = DateComponents()
        dateInfo.day = day
        dateInfo.hour = hour
        dateInfo.minute = minute
        
        return UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)
    }
    
    func makeLocationNotificationTrigger(notifyOnEntry: Bool) -> UNNotificationTrigger {
        locationManager?.startUpdatingLocation()
        locationManager?.requestLocation()
        
        let coordinates = CLLocationCoordinate2D(latitude: 37.331854728712756,
                                                 longitude: -122.0302211884243)
        let region = CLCircularRegion(center: coordinates,
                                      radius: 20,
                                      identifier: UUID().uuidString)
        region.notifyOnEntry = notifyOnEntry
        
        return UNLocationNotificationTrigger(region: region, repeats: false)
    }
}

// MARK: - Actions
extension NotificationManager: UNUserNotificationCenterDelegate {
    private func configureManager() {
        center.delegate = self
        let registrationAction = UNNotificationAction(identifier: "Registration",
                                                title: "Registration",
                                                options: [.foreground],
                                                icon: .init(systemImageName: "star"))
        let deleteAction = UNNotificationAction(identifier: "Delete",
                                                title: "Delete",
                                                options: [.destructive])
        let userActions = "User Actions"
        let category = UNNotificationCategory(identifier: userActions,
                                              actions: [registrationAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        switch response.actionIdentifier {
        case "Registration":
            print(userInfo)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Registration"),
                                            object: nil)
        case "Delete":
            clearNotificationBage()
        default:
            break
        }
        
        completionHandler()
    }
}
