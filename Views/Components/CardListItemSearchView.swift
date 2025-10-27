//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//
import SwiftUI

struct CardListItemSearchView: View {
    var volume: Item
    
    @State private var selectedBook : Item?
    
    var detents: Set<PresentationDetent> {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return [.large]
        } else {
            return [.fraction(0.75)]
        }
    }
    
    var body: some View {
        HStack {
            if let thumbnail = volume.volumeInfo.imageLinks?.thumbnail?.replacingOccurrences(of: "http", with: "https") {
                AsyncImage(url: URL(string: thumbnail), scale: 1){ image in
                    image
                        .resizable()
                        .frame(maxWidth: 63, maxHeight: 101)
                   } placeholder: {
                       ProgressView()
                }
            } else {
                Image(.addBook)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63)
            }
            
            VStack (alignment: .leading) {
                Text(volume.volumeInfo.title)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                HStack {
                    if volume.volumeInfo.authors?.count ?? 0 > 2 {
                        Text(volume.volumeInfo.authors?.first ?? "No Author")
                    } else {
                        Text(volume.volumeInfo.authors?.joined(separator: ", ") ?? "Unknown")
                            .lineLimit(1)
                    }
                }
            }
            .padding(.leading, 1)
            
            Spacer()
            
            Button {
                selectedBook = volume
            } label: {
                Label("Add a book", systemImage: "plus.app")
                    .labelStyle(.iconOnly)
                    .font(.title2)
                    .foregroundStyle(.accent)
                    .padding(.horizontal)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.shadow(.inner(color: .black.opacity(1), radius: 1, y: 1.1)))
                .opacity(0.1)
        )
        .padding(.horizontal)
        .sheet(item: $selectedBook) { book in
            VStack {
                AddBookManualView(volume: book)
            }
            .presentationDetents(detents)
        }
    }
}

#Preview {
    CardListItemSearchView(volume: Item.init(id: "1", selfLink: "https://books.google.com/books/v1/volumes/1", volumeInfo: VolumeInfo.init(title: "Test", authors: ["Me"], imageLinks: nil) ))
}


