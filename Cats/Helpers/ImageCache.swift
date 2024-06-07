//
//  ImageCache.swift
//  Cats
//
//  Created by Alberto on 24/02/24.
//

import SwiftUI

// Image Cache class to store and retrieve images
class ImageCache {
    private var cache = NSCache<NSURL, UIImage>()
    
    static let shared = ImageCache()
    
    private init() {}
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
}

struct CachedAsyncImage<Content>: View where Content: View {
    private var url: URL?
    private var scale: CGFloat
    private var transaction: Transaction
    private var content: (AsyncImagePhase) -> Content
    
    @State private var phase: AsyncImagePhase = .empty
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        loadImage()
    }
    
    var body: some View {
        content(phase)
            .onAppear {
                loadImage()
            }
    }
    
    private func loadImage() {
        guard let url = url else {
            phase = .failure(NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }
        
        if let cachedImage = ImageCache.shared.image(for: url) {
            phase = .success(Image(uiImage: cachedImage))
            return
        }
        
        phase = .empty
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let uiImage = UIImage(data: data) {
                ImageCache.shared.setImage(uiImage, for: url)
                DispatchQueue.main.async {
                    phase = .success(Image(uiImage: uiImage))
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    phase = .failure(error)
                }
            } else {
                DispatchQueue.main.async {
                    phase = .failure(NSError(domain: "Unknown error", code: -1, userInfo: nil))
                }
            }
        }
        task.resume()
    }
}

struct ContentView: View {
    let imageUrl = URL(string: "https://example.com/image.jpg")
    
    var body: some View {
        CachedAsyncImage(url: imageUrl) { phase in
            switch phase {
            case .empty:
                ProgressView()
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            case .failure:
                Image(systemName: "photo")
            @unknown default:
                EmptyView()
            }
        }
    }
}
