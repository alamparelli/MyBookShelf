//
//  NotificationService.swift
//  MyBookShelf
//
//  Manages daily reading reminder notifications for books in progress
//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import Foundation
import UserNotifications
import SwiftUI

/// Handles scheduling and managing reading reminder notifications
@Observable
class NotificationService: NSObject {
    let center = UNUserNotificationCenter.current()
    let notificationTime = UserDefaults.standard.value(forKey: "notificationTime") as? Date
    let notificationsEnabled = UserDefaults.standard.value(forKey: "notificationsEnabled") as? Bool

    /// Requests notification permissions from the user
    func askPermissions() async {
        do {
            try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            // Handle errors that may occur during requestAuthorization.
        }
    }
    
    /// Verifies notification permissions and returns current settings
    func checkAuthorizationStatus() async -> UNNotificationSettings {
        await askPermissions()
        let settings = await center.notificationSettings()
        
        return settings
    }
    
    /// Updates notification state based on book's reading status
    func updateBook(_ status: ReadingStatus, _ book: Book) async {
        let authStatus = await checkAuthorizationStatus()
        
        switch status {
        case .read, .unread:
            deleteNotification(book)
        case .reading:
            if let time = notificationTime {
                await setNotification(book, authStatus, time)
            }
        }
    }
    
    /// Reschedules all notifications for the new time
    func updateAll(_ time: Date,_ books: [Book]) async {
        deleteNotificationAll()
        
        await setNotificationAll(time, books)
    }
    
    /// Schedules daily notification for a specific book
    func setNotification(_ book: Book, _ authStatus: UNNotificationSettings, _ time : Date) async {
        guard (authStatus.authorizationStatus == .authorized) ||
                (authStatus.authorizationStatus == .provisional) else { return }
        
        if authStatus.alertSetting == .enabled {
            let content = UNMutableNotificationContent()
            content.title = "\(book.title) is waiting for you"
            content.body = "Take a bit of time to continue your reading ❤️"
            content.userInfo = ["BookId" : book.id.uuidString]
            content.categoryIdentifier = "BOOK_READING_REMINDER"
            
            var components = DateComponents()
            components = Calendar.current.dateComponents([.hour, .minute], from: time)
               
            let trigger = UNCalendarNotificationTrigger(
                     dateMatching: components, repeats: true)
            
            let identifierId = book.id.uuidString
            let request = UNNotificationRequest(identifier: "eu.lamparelli.MyBookShelf-\(identifierId)", content: content, trigger: trigger)

            let notificationCenter = UNUserNotificationCenter.current()
            do {
                try await notificationCenter.add(request)
            } catch {
                print("Notification cannot be set for the specific book : \(error.localizedDescription)")
            }
        } else {
            print("permissions not granted")
            // Schedule a notification with a badge and sound.
        }
    }
    
    /// Removes notification for a specific book
    func deleteNotification(_ book: Book) {
        var identifiers = [String]()
        
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                if request.identifier.contains(book.id.uuidString) {
                    identifiers.append(request.identifier)
                    self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
                }
            }
        })
    }
    
    /// Creates notifications for all books currently being read
    func setNotificationAll(_ time: Date,_ books: [Book]) async {
        let authStatus = await checkAuthorizationStatus()
        
        for book in books {
            await setNotification(book, authStatus, time)
        }
        
    }
    
    /// Removes all app notifications
    func deleteNotificationAll() {
        var identifiers = [String]()
        
        // Can be done better. for the moment, i think it will be ok, estimated not a lot of books at the same time oened. several book is an edge case.
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                if request.identifier.contains("eu.lamparelli.MyBookShelf") {
                    identifiers.append(request.identifier)
                    self.center.removePendingNotificationRequests(withIdentifiers: identifiers)
                }
            }
        })
    }
    
    #if DEBUG
    /// Prints all pending notifications for debugging
    func debugNotifications() {
        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print("ID: \(request.identifier) - \(request.content.title) - \(request.trigger.unsafelyUnwrapped)")
            }
        })
    }
    #endif
}
