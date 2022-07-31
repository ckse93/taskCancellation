//
//  ContentView.swift
//  TaskCancellation
//
//  Created by Chan Jung on 7/14/22.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    @State var showDetail: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Search result: total \(viewModel.numFound) results")
                
                List(viewModel.searchResult) { book in
                    BookCellView(book: book)
                        .onTapGesture {
                            viewModel.currentlySelectedBook = book
                            showDetail = true
                        }
                }
            }
            .overlay {
                if viewModel.isSearching {
                    ZStack {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .background( .regularMaterial )
                    .clipShape(Circle())
                }
            }
            .onChange(of: viewModel.searchResult.count, perform: { newValue in
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            })
            .searchable(text: $viewModel.searchTerm)
            // wait 0.8 seconds and then execute query
            .onReceive(viewModel.$searchTerm.debounce(for: 0.8, scheduler: RunLoop.main)) { searchTerm in
                Task {
                    await viewModel.executeQuery()
                }
            }
            .fullScreenCover(isPresented: $showDetail) {
                BookDetailView(book: viewModel.currentlySelectedBook!)
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
        .padding(3)
    }
}

struct BookDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let book: Book
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                
                Button("Dismiss") {
                    self.dismiss()
                }
            }
            .padding()
            
            AsyncImageWithCache(urlStr: book.largeCoverImageUrl?.absoluteString ?? "")
            
            Text(book.title)
                .font(.title)
            
            Text(book.author)
                .font(.title2)
            
            Text(book.isbn)
            
            Spacer()
        }
    }
}
