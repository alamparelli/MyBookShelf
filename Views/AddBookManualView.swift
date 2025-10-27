//
//  AddBookManualView.swift
//  MyBookShelf
//
//  Modal view for manually adding or confirming book details
//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import SwiftData
import SwiftUI

/// Form for manually entering book details or confirming Google Books selection
struct AddBookManualView: View {
    var volume: Item

    @State private var title: String = ""
    @State private var author: String = ""
    @State private var status: ReadingStatus = .unread
    @State private var imageCover: String = ""
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Environment(GBookApi.self) var gbookapi
    @Environment(NotificationService.self) var nService
    
    var body: some View {
        NavigationStack {
            VStack  {
                if !volume.selfLink.isEmpty {
                    AsyncImage(url: URL(string: imageCover)){ image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 250)
                            .clipped()
                            .ignoresSafeArea(edges: .top)
                            .brightness(-0.05) // coool :p
                       } placeholder: {
                           Image(.addBook)
                               .resizable()
                               .scaledToFill()
                               .frame(height: 250)
                               .clipped()
                               .ignoresSafeArea(edges: .top)
                               .brightness(-0.05) // coool :p
                    }
                } else {
                    Image(.addBook)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 250)
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
            .background(.creamBackground)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button{
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.accent)
                    }
                }
                if !title.isEmpty && !author.isEmpty {
                    ToolbarItem(placement: .automatic) {
                        Button{
                            Task {
                                await saveBook()
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.down.on.square")
                        }
                        .buttonStyle(.glassProminent)
                        //                    .disabled(title.isEmpty && author.isEmpty)
                    }
                }
            }
            .onAppear {
                if !volume.selfLink.isEmpty {
                    title = volume.volumeInfo.title
                    author = volume.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown"
                    Task {
                        imageCover = await gbookapi.retrieveMediumImage(volume).replacingOccurrences(of: "http", with: "https")
                    }
                }
            }
        }
    }
    
    func saveBook() async {
        // collect data and save on swiftdata
        // if added manually thumbnail do not exist, shall save the thumbnail as image and store it when coming from online
        let book = Book(title: title, author: author, status: status)
        modelContext.insert(book)
        
        await nService.updateBook(status, book) // create notification if status == reading
        
        if let thumbnail = volume.volumeInfo.imageLinks?.thumbnail {
            book.thumbnailUrl = thumbnail.replacingOccurrences(of: "http", with: "https")
            if book.thumbnailUrl != nil {
                book.downloadThumbnail()
            }
            
            book.imageUrl = await gbookapi.retrieveMediumImage(volume).replacingOccurrences(of: "http", with: "https")
            if book.imageUrl != nil {
                book.downloadImage()
            }
        }
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddBookManualView(volume: Item.init(id: "1", selfLink: "https://books.google.com/books/v1/volumes/1", volumeInfo: VolumeInfo.init(title: "Test", authors: ["Me"], imageLinks: nil) ))
        .modelContainer(for: Book.self)
}
