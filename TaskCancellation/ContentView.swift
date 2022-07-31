//
//  ContentView.swift
//  TaskCancellation
//
//  Created by Chan Jung on 7/14/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Search result: total \(viewModel.numFound) results")
                
                List(viewModel.searchResult) { book in
                    BookCellView(book: book)
                }
                .overlay {
                    if viewModel.isSearching {
                        ProgressView()
                    }
                }
            }
            .searchable(text: $viewModel.searchTerm)
            // wait 0.8 seconds and then execute query
            .onReceive(viewModel.$searchTerm.debounce(for: 0.8, scheduler: RunLoop.main)) { searchTerm in
                Task {
                    await viewModel.executeQuery()
                }
            }
        }
    }
}

struct BookCellView: View {
    let book: Book
    
    var body: some View {
        HStack {
            AsyncImageWithCache(urlStr: book.smallCoverImageUrl?.absoluteString ?? "")
            
            Text(book.title)
                .font(.title2)
            
            Text(book.author)
        }
    }
}

struct BookDetailView: View {
    let book: Book
    
    var body: some View {
        VStack {
            
        }
    }
}
