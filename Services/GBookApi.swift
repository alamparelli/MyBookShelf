//
//  GBookApi.swift
//  MyBookShelf
//
//  Service for searching and fetching book data from Google Books API
//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import Foundation

/// Manages Google Books API interactions for book searches
@Observable
class GBookApi {
    var searchTerms: String
    var results : [Item]
    
    let url = "https://www.googleapis.com/books/v1/volumes?q="
    
    init(searchTerms: String = "", results: [Result] = []) {
        self.searchTerms = searchTerms
        self.results = []
    }
    
    var searchUrl: URL? {
        URL(string: "\(url)\(self.searchTerms)")!
    }
    
    var searchCount: Int {
        self.results.count
    }
    
    /// Constructs search query with optional author filter
    func setSearchterm(_ title: String, _ author: String = "") {
        var terms: String = ""
        if author.isEmpty {
            terms = title
        } else {
            terms = "intitle:\(title)+inauthor:\(author)"
        }
        terms += "&maxResults=40"
        self.searchTerms = terms.replacingOccurrences(of: " ", with: "+")
    }
    
    /// Searches Google Books API and populates results array
    func retrieveResult(_ title: String, _ author: String = "") async {
        self.results = []
        self.setSearchterm(title, author)
        
        guard let url = self.searchUrl else { return }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(Result.self, from: data)
            self.results = items.items
            
        } catch {
            print("Failed to retrieve data from GoogleApi \(error.localizedDescription)")
            return
        }
    }
    
    /// Fetches higher resolution image URL for a specific book
    func retrieveMediumImage(_ volume: Item) async -> String {
        do {
            let (data, _ ) = try await URLSession.shared.data(from: URL(string: volume.selfLink)!)
            let item = try JSONDecoder().decode(Item.self, from: data)
            return item.volumeInfo.imageLinks?.medium ?? ""
        } catch {
            return "failed to retrieve the medium size image url"
        }
    }
    
    /// Placeholder item for manual book entry
    var emptyItem = Item(id: "1", selfLink: "", volumeInfo: VolumeInfo.init(title: "", authors: [""], imageLinks: nil) )
}
