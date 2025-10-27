//
//  SettingsView.swift
//  MyBookShelf
//
//  App preferences including sorting options and notification settings
//

import SwiftData
import SwiftUI

/// Manages app settings for sorting, notifications, and app information
struct SettingsView: View {
    @AppStorage("dSortOption") var dSortOption = BookSortOptions.added
    @AppStorage("dSortOrder") var dSortOrder = BookSortOrder.ascending
    @AppStorage("notificationsEnabled") var notificationsEnabled = false
    @AppStorage("notificationTime") var notificationTime: Date = Date()
    
    let privacyUrl = URL(string: "https://google.com")!
    let termsUrl = URL(string: "https://google.com")!
    let jarredCredits = URL(string: "https://unsplash.com/fr/@jaredd?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText")!
    
    @Environment(NotificationService.self) var nService
    @Environment(AppDelegate.self) var appDelegate

    
    @Query var books: [Book]
    
    var bookInProgress: [Book] {
        return books.filter { book in
            book.status == .reading
        }
    }
        
    var body: some View {
        @Bindable var appDelegate = appDelegate

        NavigationStack (path: $appDelegate.navigationPath) {
            VStack {
                Form {
                    Section ("Default Sorting") {
                        Picker("Sort", selection: $dSortOption) {
                            ForEach(BookSortOptions.allCases, id: \.self) { option in
                                Text(option.rawValue.capitalized)
                            }
                        }
                        Picker("Order", selection: $dSortOrder) {
                            ForEach(BookSortOrder.allCases, id: \.self) { option in
                                Text(option.rawValue.capitalized)
                            }
                        }
                    }
                    
                    Section("Notifications") {
                        Toggle(isOn: $notificationsEnabled) {
                            Text("Reading Reminders")
                            Text("Only for started book")
                        }
                        .onChange(of: notificationsEnabled) { oldValue, newValue in
                            if newValue == true {
                                Task {
                                    await nService.setNotificationAll(notificationTime, bookInProgress)
                                }
                            } else {
                                Task {
                                    nService.deleteNotificationAll()
                                }
                            }
                        }
                        DatePicker("Time of the day", selection: $notificationTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationTime) {
                                Task {
                                    await nService.updateAll(notificationTime, bookInProgress)
                                }
                            }
                    }
                    
                    #if DEBUG
                    Button("Debug Notification") {
                        Task {
                            nService.debugNotifications()
                        }
                    }
                    #endif
                    
                }
                .scrollContentBackground(.hidden)
                
                Spacer()
                
                VStack {
                    Text("App version: \(UIApplication.build)")
                    HStack {
                        Link("Privacy Policy", destination: privacyUrl)
                        Text("-")
                        Link("Terms of Use", destination: privacyUrl)
                    }
                    
                    Link("Image credits: by Jaredd Craig (Unsplash)", destination:  jarredCredits)
                        .padding(.top)
                }
                .font(.caption)
                .padding(.bottom)
                
            }
            .navigationTitle("Settings")
            .navigationDestination(for: String.self) { book in
                BookDetailView(bookId: book)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .background(.creamBackground)
        }
        
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.accent]
    }
}

#Preview {
    SettingsView()
}
