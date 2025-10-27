//
//  MyBookShelfApp.swift
//  MyBookShelf
//
//  Main app entry point and configuration
//

import SwiftData
import SwiftUI
import UserNotifications

/// Main app configuration with SwiftData and environment setup
@main
struct MyBookShelfApp: App {
    var gbookapi: GBookApi = GBookApi()
    var nService: NotificationService = NotificationService()
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .fontDesign(.rounded)
                .preferredColorScheme(.light)
        }
        .modelContainer(for: Book.self)
        .environment(gbookapi)
        .environment(nService)
        .environment(appDelegate)
    }
}

/// Handles app lifecycle and notification tap responses
@Observable
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    /// Navigation stack for deep linking from notifications
    var navigationPath = [String]()
    
    func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    /// Shows notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.sound, .banner, .list]
    }
        
    /// Navigates to book detail when notification is tapped
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        if let pageLink = response.notification.request.content.userInfo["BookId"] as? String {
            if navigationPath.last != pageLink {
                //Optional
//                navigationPath = []
                // Push the page
                navigationPath.append(pageLink)
            }
        }
        completionHandler()
    }
}
