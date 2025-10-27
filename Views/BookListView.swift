//
//  BookListView.swift
//  MyBookShelf
//
//  Main library view displaying the user's book collection
//

import SwiftData
import SwiftUI

struct IsSearchable: ViewModifier {
    let selectedTab: Int
    @Binding var searchText: String

    func body(content: Content) -> some View {
        if selectedTab == 3 {
            content
                .searchable(text: $searchText)
        } else {
            content
        }
    }
}

extension View {
    func isSearchable(selectedTab: Int, searchText: Binding<String>) -> some View {
        modifier(IsSearchable(selectedTab: selectedTab, searchText: searchText))
    }
}

/// Displays the user's book collection with sorting and search capabilities
struct BookListView: View {
    @Query var books: [Book]
    
    @Environment(\.modelContext) var modelContext
    
    @State private var searchText = ""
    @State private var addNewBook = false
    
    @State private var selectedBook: Book?
    @State private var showConfirmationDialog = false
    
    var selectedTab: Int
    
    @AppStorage("dSortOption") var dSortOption = BookSortOptions.added
    @AppStorage("dSortOrder") var dSortOrder = BookSortOrder.ascending

    @Environment(NotificationService.self) var nService
    @Environment(AppDelegate.self) var appDelegate
    
    let columns = [GridItem(.flexible())]
    
    var searchedBooks: [Book] {
        if searchText.isEmpty {
            return books
        } else {
            return try! books.filter(#Predicate<Book> { book in
                book.author.localizedStandardContains(searchText) || book.title.localizedStandardContains(searchText)
            })
        }
    }
    
    var sortedBooks: [Book] {
        let books = searchedBooks.sorted { book1, book2 in
            var comparison: Bool
            
            switch dSortOption {
            case .added:
                comparison = book1.added < book2.added
            case .author:
                comparison = book1.author < book2.author
            case .title:
                comparison = book1.title < book2.title
            case .status:
                comparison = book1.status.rawValue  < book2.status.rawValue
            }
            
            return dSortOrder == .ascending ? comparison : !comparison
        }
        
        return books
    }
    
    var body: some View {
        @Bindable var appDelegate = appDelegate

        NavigationStack (path: $appDelegate.navigationPath) {
            VStack {
                if books.isEmpty {
                    NavigationLink {
                        AddBookView()
                    } label: {
                        ContentUnavailableView {
                            Label("Nothing yet here...", systemImage: "book.closed")
                                .foregroundStyle(.accent)
                        } description: {
                            Text("Add a book to start enjoying some statistics.")
                                .foregroundStyle(.accent)
                        }
                    }
                } else {
                    List {
                        ForEach(sortedBooks) { book in
                            CardListItemView(book: book, selectedBook : $selectedBook)
                                .swipeActions {
                                    Button{
                                        showConfirmationDialog = true
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                            .tint(.red)
                                    }
                                }
                                .confirmationDialog("Delete this book?", isPresented: $showConfirmationDialog) {
                                    Button("Confirm", role: .destructive) {
                                        modelContext.delete(book)
                                        Task {
                                            await nService.updateBook(.unread, book) // delete notification for this book
                                        }
                                    }
                                } message: {
                                    Text("Delete this book?")
                                }
                        }
                        .listRowBackground(Color.creamBackground)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 5,
                                              leading: 16,
                                              bottom: 5,
                                              trailing: 16))
                    }
                    .listStyle(.plain)
                    .navigationDestination(item: $selectedBook) { book in
                        BookDetailView(bookId: book.id.uuidString)
                    }

//                    ScrollView {
//                        LazyVGrid(columns: columns) {
//                            ForEach(sortedBooks) { book in
//                                CardListItemView(book: book)
//                            }
//                        }
//                    }
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .scrollIndicators(.never)
            .background(.creamBackground)
            .fontDesign(.rounded)
            .isSearchable(selectedTab: selectedTab, searchText: $searchText)
            .navigationTitle("My BookShelf")
            .navigationDestination(for: String.self) { book in
                BookDetailView(bookId: book)
            }
            .toolbarTitleDisplayMode(.inlineLarge)
            .toolbar {
                ToolbarItem (placement: .primaryAction) {
                    NavigationLink {
                        AddBookView()
                    } label: {
                        Image(systemName: "plus.app")
                            .accessibilityHint("Add a book")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
                ToolbarItemGroup {
                    Menu {
                        Button(BookSortOptions.title.rawValue, systemImage: "text.book.closed") {
                            dSortOption = .title
                        }
                        Button(BookSortOptions.author.rawValue, systemImage: "person") {
                            dSortOption = .author
                        }
                        Button(BookSortOptions.added.rawValue, systemImage: "calendar.badge.plus") {
                            dSortOption = .added
                        }
                        Button(BookSortOptions.status.rawValue, systemImage: "book.closed") {
                            dSortOption = .status
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundStyle(Color.accentColor)
                    }
                    .accessibilityLabel("Sort by")
                    
                }
            }
        }

    }
    
    init(selectedTab: Int) {
        self.selectedTab = selectedTab
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.accent]
    }
}

#Preview {
    BookListView(selectedTab: 0)
        .modelContainer(for: Book.self)
}
