//
//  AppDelegate.swift
//  GB_Frameworks
//
//  Created by Vitaliy Talalay on 15.05.2022.
//

import UIKit
import GoogleMaps
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: ApplicationCoordinator?
    var notificationManager: NotificationManager?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        GMSServices.provideAPIKey(GoogleServiceKeys.APIKeyForMaps)
        RealmService.defaultConfig()
    
//        requestStandartAutorization()
        requestProvisionalAuthorization()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        sendIntervalNotification()
    }

    private func requestStandartAutorization() {
        notificationManager = NotificationManager.instance
        notificationManager?.requestAutorization(options: [.alert, .sound, .badge])
    }
    
    private func requestProvisionalAuthorization() {
        notificationManager = NotificationManager.instance
        notificationManager?.requestAutorization(options: [.alert, .sound, .badge, .provisional])
    }
    
    private func sendIntervalNotification() {
        let body = "Приложение закрыто уже 10 секунд, это надо исправить"
        
        guard let manager = notificationManager else { return }
        let content = manager.makeNotificationContent(title: "Внимание",
                                                      subtitle: "Внимание",
                                                      body: body,
                                                      badge: 1,
                                                      actionsIdentifier: "")
        let trigger = manager.makeIntervalNotificatioTrigger(timeInterval: 10.0,
                                                             repeats: false)
        
        manager.sendNotificationRequest(content: content, trigger: trigger, identifier: "Registration")
    }
}

