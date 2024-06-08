//
//  AppDelegate.swift
//  fit3178_majorAssignment
//
//  Created by Chin Yen Tung on 1/5/2024.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var databaseController: DatabaseProtocol?
    
    var notificationsEnabled = false
    static let INTERVIEW_STARTTIME_NOTIF_IDENTIFIER = "jobApplicationTrackerPrepApp.interview.starttime" // just need to make sure it's unique
    static let INTERVIEW_REMINDER_NOTIF_IDENTIFIER = "jobApplicationTrackerPrepApp.interview.reminder"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        databaseController = DatabaseController()
        
        // set up notification settings
        // done in an async code
        Task {
            let notificationCenter = UNUserNotificationCenter.current()
            let notificationSettings = await notificationCenter.notificationSettings() // ask for notification settings
            
            // check for permission settings authorization status
            if notificationSettings.authorizationStatus == .notDetermined {
                let granted = try await notificationCenter.requestAuthorization(options: [.alert])
                self.notificationsEnabled = granted  // set to true or false depending on whether permissions were granted
            }
            else if notificationSettings.authorizationStatus == .authorized {
                self.notificationsEnabled = true
            }
        }

        // Because notifications are delivered very quickly at the beginning of the app launching,
        // we need to make sure that we've set ourselves up as a delegate either in both or either
        // applicationWillLaunch or applicationDidLaunch methods.
        // If we do it any later, the notifications will be missed.
        UNUserNotificationCenter.current().delegate = self
        
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
    
    
    // MARK: UNUserNotificationCenterDelegate methods

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        // by default, ios doesnt show notifs when the app is visible
        // if return [], notification doesnt show up
        return [.banner] //"banner" is the type of notification we want to allow
    }
}

