//
//  AddBookView.swift
//  MyBookShelf
//
//  Search interface for finding and adding books from Google Books API
//
// Copyright (c) 2025. Created by Alessandro L. All rights reserved.
//

import SwiftUI

/// View for searching and adding books from Google Books or manually
struct AddBookView: View {
    @Environment(GBookApi.self) var gbookapi

    @State private var searchTitle : String = ""
    @State private var searchAuthor : String = ""
    
    @State private var loadingState = LoadingState.idle
    @State private var showSearchbyAuthor = false
    
    @State private var selectedBook: Item?
    @State private var showAddManually = false

    
    enum LoadingState {
        case loading, loaded, idle, noresult
    }
    
    var body: some View {
            VStack {
                if loadingState == .loaded {
                    ScrollView {
                        ForEach(gbookapi.results, id:\.id) { volume in
                            CardListItemSearchView(volume: volume)
                        }
                    }
                } else if loadingState == .loading {
                    ContentUnavailableView {
                        Label("Gathering Results", systemImage: "arrow.trianglehead.clockwise.rotate.90")
                            .symbolEffect(.rotate.byLayer, options: .repeat(.continuous))
                            .foregroundStyle(.accent)
                    } description: {
                        Text("Just a moment...")
                            .foregroundStyle(.accent)
                    }
                } else if loadingState == .idle{
                    Button {
                        showAddManually = true
                    } label: {
                        ContentUnavailableView {
                            Label("Add a book", systemImage: "plus.app")
                                .foregroundStyle(.accent)
                        } description: {
                            Text("or search a book here below")
                                .foregroundStyle(.accent)
                        }
                    }
                } else if loadingState == .noresult {
                    Button {
                        showAddManually = true
                    } label: {
                        ContentUnavailableView {
                            Label("No result found", systemImage: "plus.app")
                                .foregroundStyle(.accent)
                        } description: {
                            Text("Add a book manually")
                                .foregroundStyle(.accent)
                        }
                    }
                }
                
                HStack {
                    VStack (spacing: 1) {
                        TextField("Search online", text: $searchTitle.animation())
                            .padding()
                            .background(.white)
                            .overlay{
                                if !searchTitle.isEmpty {
                                    HStack (alignment: .center) {
                                        Spacer()
                                        Button {
                                            withAnimation {
                                                searchTitle = ""
                                                searchAuthor = ""
                                                showSearchbyAuthor = false
                                            }
                                        } label: {
                                            Image(systemName: "x.circle.fill")
                                                .accessibilityHint("clean field")
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        if showSearchbyAuthor {
                            TextField("Search Author", text: $searchAuthor)
                                .padding()
                                .background(.white)
                                .overlay{
                                    if !searchAuthor.isEmpty {
                                        HStack (alignment: .center) {
                                            Spacer()
                                            Button {
                                                searchAuthor = ""
                                            } label: {
                                                Image(systemName: "x.circle.fill")
                                                    .accessibilityHint("clean field")
                                            }
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                        }
                    }
                    .clipShape(
                        RoundedRectangle(cornerRadius: 30)
                    )
                    .onSubmit {
                        searchBook()
                    }
                    
                    if !searchTitle.isEmpty {
                        GlassEffectContainer(spacing: 40){
                            HStack {
                                Button {
                                    withAnimation {
                                        showSearchbyAuthor.toggle()
                                    }
                                } label: {
                                    Label("Search By Author", systemImage: "person.crop.circle")
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(.accent)
                                        .padding()
                                        .background(.white)
                                        .clipShape(.circle)
                                }
                                .glassEffect()
                                
                                Button {
                                    searchBook()
                                } label: {
                                    Label("Search", systemImage: "magnifyingglass")
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(.accent)
                                        .padding()
                                        .background(.white)
                                        .clipShape(.circle)
                                }
                                .glassEffect()
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .fontDesign(.rounded)
            .navigationTitle("Add a Book")
            .background(.creamBackground)
            .toolbarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .toolbar {
                ToolbarItem (placement: .primaryAction) {
                    Button {
                        showAddManually = true
                    } label: {
                        Image(systemName: "plus.app")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accentColor)
                }
            }
            .sheet(isPresented: $showAddManually) {
                VStack {
                    if let book = selectedBook {
                        AddBookManualView(volume: book)
                    } else {
                        AddBookManualView(volume: gbookapi.emptyItem)
                    }
                }
                .presentationDetents([.fraction(0.75)])
            }
    }
    
    func searchBook() {
        Task {
            withAnimation {
                loadingState = .loading
            }
            await  gbookapi.retrieveResult(searchTitle, searchAuthor)
            
            withAnimation {
                if gbookapi.searchCount == 0 {
                    loadingState = .noresult
                } else {
                    loadingState = .loaded
                }
            }
        }
    }
    
    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.accent]
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.accent]
    }
}

#Preview {
    AddBookView()
}
