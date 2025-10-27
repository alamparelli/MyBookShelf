//
//  GoogleBooksModels.swift
//  MyBookShelf
//
//  Data models for Google Books API responses
//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import Foundation

/// Root response object from Google Books API search
struct Result: Codable {
    let items: [Item]
}

/// Individual book volume from Google Books
struct Item: Codable, Identifiable {
    let id: String
    let selfLink: String
    let volumeInfo: VolumeInfo
}

/// Book metadata including title, authors, and images
struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let imageLinks: ImageLinks?
}

/// Available image URLs in different sizes
struct ImageLinks: Codable {
    let smallThumbnail: String?
    let thumbnail: String?
    let medium: String?
}
