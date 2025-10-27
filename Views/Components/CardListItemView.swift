//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import SwiftUI

struct CardListItemView: View {
    var book: Book
    @Binding var selectedBook: Book?

//    @State private var bookToOpen: Book?
    
    var body: some View {
        Button {
            selectedBook = book
        } label: {
            HStack {
                Image(uiImage: book.thumbnailImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 63)
                VStack (alignment: .leading) {
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                        .foregroundStyle(.black)
                    Text(book.author)
                        .lineLimit(1)
                        .foregroundStyle(.black.secondary)
                }
                
                Spacer()
                
                if book.status != .unread {
                    Image(systemName: book.logoStatus)
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
//            .padding(.horizontal)
        }
    }
}


#Preview {
    CardListItemView(book: Book(title: "Test", author: "Me", status: .reading), selectedBook: .constant(Book(title: "Test", author: "Me", status: .reading)))
}


