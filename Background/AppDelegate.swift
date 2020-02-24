//
//  AppDelegate.swift
//  Background
//
//  Created by Hannes Tribus on 22/02/2020.
//  Copyright © 2020 3Bus. All rights reserved.
//

import UIKit
import BackgroundTasks

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //Confirm Delegete and request for permission
        notificationCenter.delegate = self
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        notificationCenter.requestAuthorization(options: options) { (granted, error) in
            // If granted comes true you can enabled features based on authorization.
            guard granted else { return }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
        
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "it.3bus.Background.connectivity", using: nil) { (task: BGTask) in
            print("handle task")
            if let task = task as? BGProcessingTask {
                self.handleConnectivityCheck(task: task)
            }
        }
        
        return true
    }
    
    // MARK: Backgroundsession
    
    func handleConnectivityCheck(task: BGProcessingTask) {
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
        }
        DispatchQueue.main.async {
            self.scheduleNotification(notificationType: "Local Notification with Content")
            task.setTaskCompleted(success: true)
        }
        scheduleConnectivityCheck()
    }
    
    func scheduleConnectivityCheck() {
        let request = BGProcessingTaskRequest(identifier: "it.3bus.Background.connectivity")
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = false
        do {
            try BGTaskScheduler.shared.submit(request)
            print("task \(request.identifier) scheduled")
        } catch {
            print("Unable to submit task: \(error.localizedDescription)")
        }
        
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
    
    
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func scheduleNotification(notificationType: String) {
        
        //Compose New Notificaion
        let content = UNMutableNotificationContent()
        let categoryIdentifire = "Delete Notification Type"
        content.sound = UNNotificationSound.default
        content.body = "This is example how to send " + notificationType
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        
        //Add attachment for Notification with more content
        if (notificationType == "Local Notification with Content")
        {
            let imageName = "Apple"
            guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
            let attachment = try! UNNotificationAttachment(identifier: imageName, url: imageURL, options: .none)
            content.attachments = [attachment]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        //Add Action button the Notification
        if (notificationType == "Local Notification with Action")
        {
            let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
            let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
            let category = UNNotificationCategory(identifier: categoryIdentifire,
                                                  actions: [snoozeAction, deleteAction],
                                                  intentIdentifiers: [],
                                                  options: [])
            notificationCenter.setNotificationCategories([category])
        }
    }
    
    //Handle Notification Center Delegate methods
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }
        completionHandler()
    }
}
