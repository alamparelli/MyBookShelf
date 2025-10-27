//
//  Book.swift
//  MyBookShelf
//
//  Core book model and related types for the library
//

import SwiftData
import SwiftUI
import Foundation

/// Represents the reading progress state of a book
enum ReadingStatus: String, Codable, CaseIterable {
    case unread = "To Read"
    case reading = "Reading"
    case read = "Finished"
}

/// Available sorting options for the book list
enum BookSortOptions: String, CaseIterable, Codable {
    case title = "by title"
    case author = "by author"
    case status = "by status"
    case added = "by date added"
}

/// Sort direction for book list display
enum BookSortOrder: String, CaseIterable, Codable {
    case ascending
    case descending
}

/// Core data model representing a book in the user's library
@Model
class Book {
    var id: UUID
    var title: String
    var author: String
    var status: ReadingStatus
    var added: Date
    @Attribute(.externalStorage) var image: Data?
    @Attribute(.externalStorage) var thumbnail: Data?
    
    var thumbnailUrl: String?
    var imageUrl: String?

    init(title: String, author: String, status: ReadingStatus, added: Date = .now, image: Data? = nil, thumbnail: Data? = nil) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.status = status
        self.added = added
        self.image = image
        self.thumbnail = thumbnail
    }
    
    /// Returns thumbnail UIImage, falls back to default if no data
    var thumbnailImage: UIImage{
        if let imageData = thumbnail, let uiImage = UIImage(data: imageData) {
            return uiImage
        } else {
            return .addBook
        }
    }
    
    /// Returns full-size UIImage, falls back to default if no data
    var uiImage: UIImage{
        if let imageData = image, let uiImage = UIImage(data: imageData) {
            return uiImage
        } else {
            return .addBook
        }
    }
    
    /// SF Symbol name representing the book's reading status
    var logoStatus: String {
        switch status {
        case .read:
            return "book.closed"
        case .unread:
            return ""
        case .reading:
            return "book"
        }
    }
    
    /// Downloads and stores thumbnail image from thumbnailUrl
    func downloadThumbnail() {
        if let str = thumbnailUrl {
            let url = URL(string: str)
            let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
                if let imageData = data {
                    self.thumbnail = imageData
                }
            }
            task.resume()
        }
    }
    
    /// Downloads and stores full-size image from imageUrl
    func downloadImage() {
        if let str = imageUrl {
            if let url = URL(string: str) {
                let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                    if let imageData = data {
                        self.image = imageData
                    }
                }
                task.resume()
            }
        }
    }
}
