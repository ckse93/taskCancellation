//
//  SwiftUIView.swift
//  TaskCancellation
//
//  Created by Chan Jung on 7/14/22.
//

import SwiftUI

struct AsyncImageWithCache: View {
    @ObservedObject var viewModel: AsyncImageWithCacheViewModel
    
    init(urlStr: String) {
        self.viewModel = AsyncImageWithCacheViewModel(urlStr: urlStr)
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                ProgressView()
            } else {
                Image(uiImage: UIImage(data: viewModel.imgData)!)
                    .resizable()
            }
        }
        .task {
            await viewModel.fetchData()
        }
    }
}

//extension AsyncImageWithCache {
//    func frame() -> some View {
//        modifier(<#T##T#>)
//    }
//}

class AsyncImageWithCacheViewModel: ObservableObject {
    let urlStr: String
    private let urlSession: URLSession = URLSession(configuration: .default)
    @Published var isLoading: Bool = true
    @Published var imgData: Data!
    
    init(urlStr: String) {
        self.urlStr = urlStr
    }
    
    @MainActor func fetchData() async {
        self.isLoading = true
        guard let url = URL(string: urlStr) else {
            print("cannot make url for image")
            return
        }
        let request: URLRequest = URLRequest(url: url)
        
        if let cachedResponse = URLCache.shared.cachedResponse(for: request) {
            print("found cache!")
            self.imgData = cachedResponse.data
            self.isLoading = false
            return
        }
        
        do {
            let (data, response) = try await urlSession.data(from: url)
            URLCache.shared.storeCachedResponse(CachedURLResponse(response: response, data: data), for: request)
            self.imgData = data
            self.isLoading = false
            return
        } catch(let error) {
            print("cannot fetch imagedata, error: \(error.localizedDescription) for url: \(urlStr)")
        }
    }
}
