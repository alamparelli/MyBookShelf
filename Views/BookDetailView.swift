//
//  BookDetailView.swift
//  MyBookShelf
//
//  Detailed view for editing book information and status
//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import SwiftData
import SwiftUI

/// Displays and allows editing of individual book details
struct BookDetailView: View {
//    var book: Book
    var bookId : String
    
    @Query private var books: [Book]
    
    private var book: Book? {
        books.first
    }
    
    init(bookId: String) {
        self.bookId = bookId
        
        if let uuid = UUID(uuidString: bookId) {
            _books = Query(filter: #Predicate<Book> { book in
                book.id == uuid
            })
        } else {
            _books = Query(filter: #Predicate<Book> { _ in false })
        }
    }


    @State private var title: String = ""
    @State private var author: String = ""
    @State private var status: ReadingStatus = .unread
    @State private var imageCover: String = ""
    @State private var showConfirmationDialog = false
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(GBookApi.self) var gbookapi
    @Environment(NotificationService.self) var nService
    
    var body: some View {
        if let book = book {
            ScrollView {
                VStack  {
                    if book.image != nil {
                        Image(uiImage: book.uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 500)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                            .brightness(-0.05) // coool :p
                    } else if book.image == nil && book.thumbnail != nil {
                        Image(uiImage: book.thumbnailImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 500)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                            .brightness(-0.05) // coool :p
                    } else {
                        Image(.addBook)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 500)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                            .brightness(-0.05) // coool :p
                    }
                    
                    VStack {
                        VStack (alignment: .leading){
                            Text("Title")
                                .foregroundStyle(Color.accent)
                            Divider()
                                .padding(.horizontal)
                            TextField("Title", text: $title)
                                .padding(.horizontal)
                                .overlay {
                                    if !title.isEmpty {
                                        HStack (alignment: .center) {
                                            Spacer()
                                            Button {
                                                title = ""
                                            } label: {
                                                Image(systemName: "x.circle.fill")
                                                    .accessibilityHint("clean field")
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                        }
                        .padding(.bottom)
                        
                        VStack (alignment: .leading){
                            Text("Author")
                                .foregroundStyle(Color.accent)
                            Divider()
                                .padding(.horizontal)
                            TextField("Author", text: $author)
                                .padding(.horizontal)
                                .overlay {
                                    if !author.isEmpty {
                                        HStack (alignment: .center) {
                                            Spacer()
                                            Button {
                                                author = ""
                                            } label: {
                                                Image(systemName: "x.circle.fill")
                                                    .accessibilityHint("clean field")
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                        }
                        .padding(.bottom)
                        
                        VStack (alignment: .leading){
                            Text("Added")
                                .foregroundStyle(Color.accent)
                            Divider()
                                .padding(.horizontal)
                            Text(book.added.formatted(date: .abbreviated, time: .omitted))
                                .padding(.horizontal)
                        }
                        .padding(.bottom)
                        
                        VStack (alignment: .leading){
                            Text("Status")
                                .foregroundStyle(Color.accent)
                            Picker("Reading Status", selection: $status) {
                                ForEach(ReadingStatus.allCases, id: \.self) { sta in
                                    Text(sta.rawValue)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                    .padding()
                    
                    Spacer()
                }
                .onChange(of: status, { oldValue, newValue in
                    Task {
                        await nService.updateBook(newValue, book)
                    }
                })
                .toolbar(.hidden, for: .tabBar)
                .toolbar {
                    ToolbarItem(placement: .destructiveAction) {
                        Button{
                            showConfirmationDialog = true
                        } label: {
                            Image(systemName: "trash")
                        }
                        .confirmationDialog("Delete this book?", isPresented: $showConfirmationDialog) {
                            Button("Confirm", role: .destructive) {
                                modelContext.delete(book)
                                Task {
                                    await nService.updateBook(.unread, book) // delet notification for this book
                                }
                                dismiss()
                            }
                        } message: {
                            Text("Delete this book?")
                        }
                    }
                }
                .onAppear {
                    title = book.title
                    author = book.author
                    status = book.status
                    
                }
                .onDisappear{
                    book.title = title
                    book.author = author
                    book.status = status
                }
            }
            .background(.creamBackground)
            .scrollBounceBehavior(.basedOnSize)
            .ignoresSafeArea()
        }
    }
}

#Preview {
    BookDetailView(bookId: UUID().uuidString)
        .modelContainer(for: Book.self)
}
