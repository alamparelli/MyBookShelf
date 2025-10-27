//
//  ContentView.swift
//  MyBookShelf
//
//  Root tab view container for the app's main navigation
//

import SwiftUI

/// Main tab view container with shelf, stats, settings, and search tabs
struct ContentView: View {
    @State private var searchText: String = ""
    @State private var showSearchBar: Bool = false
    @State private var selectedTab = 0
        
    var body: some View {
        TabView (selection: $selectedTab.animation()) {
            Tab("Shelf", systemImage: "books.vertical.fill", value : 0) {
                BookListView(selectedTab: selectedTab)
            }
            
            Tab("Stats", systemImage: "tray.and.arrow.up.fill", value : 1) {
                StatsView()
            }
            
            Tab("Settings", systemImage: "gearshape.fill", value : 2) {
                SettingsView()
            }
            
            Tab("Search", systemImage: "magnifyingglass", value : 3, role: .search) {
                BookListView(selectedTab: selectedTab)
            }
        }
        .searchToolbarBehavior(.minimize)
        .searchable(text: $searchText, prompt: "Search...")
    }
}

#Preview {
    ContentView()
}
