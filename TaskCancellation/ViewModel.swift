//
//  ViewModel.swift
//  TaskCancellation
//
//  Created by Chan Jung on 7/14/22.
//

import Foundation
import SwiftUI

final class ViewModel: ObservableObject {
    @Published var searchTerm: String = ""
    @Published var numFound: Int = 0
    @Published var searchResult: [Book] = []
    @Published var isSearching: Bool = false
    var currentlySelectedBook: Book?
    
    private var task: Task<Void, Never>?
    
    @MainActor func executeQuery() async {
        isSearching = true
        task?.cancel()  // if task is running for some search, then cancel it
        
        let searchTerm: String = searchTerm.trimmingCharacters(in: .whitespacesAndNewlines)
        if searchTerm.isEmpty {
            searchResult = []
            isSearching = false
        } else {
            task = Task {  // assigning a new task to `self.task` so if we need to cancel this, we know which one to mess with
                isSearching = true
                let (bookSearchResult, num) = await searchBooks()
                self.numFound = num
                self.searchResult = bookSearchResult
                if !Task.isCancelled {  // if at this point, if task is still running, then no more searching
                    isSearching = false
                } else {
                    print("task cancelled!")
                }
            }
        }
    }
    
    func searchBooks() async -> (books: [Book], numFound: Int) {
        let encodedSearchTerm = searchTerm.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
        guard let url = URL(string: "https://openlibrary.org/search.json?q=\(encodedSearchTerm)") else {
            return ([], 0)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let searchResult = try OpenLibrarySearchResult.init(data: data)
            guard let libraryBooks = searchResult.books else {
                return ([], 0)
            }
            return (libraryBooks.compactMap {Book.init(from: $0)}, searchResult.numFound ?? 0)
        } catch (let error) {
            print("error here: \(error.localizedDescription)")
            return ([], 0)
        }
    }
}
