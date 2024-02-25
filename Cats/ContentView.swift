//
//  ContentView.swift
//  Cats
//
//  Created by Alberto on 23/02/24.
//

import SwiftUI

struct Cat: Codable, Identifiable {
    let id: String
    let size: Double
    let tags: [String]
    let mimetype: MimeType
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case tags
        case mimetype
    }
    
    enum MimeType: String, Codable {
        case jpeg = "image/jpeg"
        case png = "image/png"
    }
    
    var imageURL: URL? {
        return URL(string: "https://cataas.com/cat/\(id)")
    }
    
    var multipleTags: [String] {
        return tags + tags + tags
    }
    
}

extension Cat {
    
    private static let likedCatsKey = "catsLiked" // Use a static constant for UserDefaults key
    
    private static func updateLikedCats(updateHandler: (inout [String: Bool]) -> Void) {
        var likedCats = UserDefaults.standard.dictionary(forKey: likedCatsKey) as? [String: Bool] ?? [:]
        updateHandler(&likedCats)
        UserDefaults.standard.set(likedCats, forKey: likedCatsKey)
    }
    
    func isLiked() -> Bool {
        guard let likedCats = UserDefaults.standard.dictionary(forKey: Self.likedCatsKey) as? [String: Bool] else {
            return false
        }
        return likedCats[id] == true
    }
    
    func like() {
        Self.updateLikedCats { likedCats in
            likedCats[id] = true
        }
    }
    
    func dislike() {
        Self.updateLikedCats { likedCats in
            likedCats.removeValue(forKey: id)
        }
    }
}

struct ContentView: View {
    
    @State var cats: [Cat] = []
    @State var selectedTag: String? {
        didSet {
            showTagSearch = selectedTag != nil
        }
    }
    
    @State private var showTagSearch: Bool = false
    
    let requestUrl: URL? = URL(string: "https://cataas.com/api/cats?skip=0&limit=10")
    
    private let adaptiveColumns = [
        GridItem(.flexible())
    ]
    
    private let numberOfColumns = [
        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 2),
        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 2),
        GridItem(.flexible(minimum: 100, maximum: 200), spacing: 2),
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: adaptiveColumns, spacing: 2) {
                ForEach(cats) { cat in
                    CatCard(cat: cat) { tag in
                        selectedTag = tag
                    }
                }
            }
        }
        .task {
            do {
                cats = try await getCats()
            } catch CatError.invalidURL {
                print("invalid URL")
            } catch CatError.invalidResponse {
                print("invalid Error")
            } catch {
                print("Unexpected error: ", error)
            }
        }
        .sheet(isPresented: $showTagSearch) {
            if let selectedTag = selectedTag {
                Text(selectedTag)
            }
        }
    }
    
    func getCats() async throws -> [Cat] {
        guard let url = requestUrl else {
            throw CatError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw CatError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let catJson = try JSONSerialization.jsonObject(with: data)
            print("catJson: ", catJson)
            
            let cat = try decoder.decode([Cat].self, from: data)
            return cat
        } catch {
            throw error
        }
        
    }
}

enum CatError: Error {
    case invalidURL
    case invalidResponse
}

#Preview {
    ContentView()
}

struct CatCard: View {
    @State var trigger = 0
    
    let cat: Cat
    
    var onTagSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: cat.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: .infinity)
                        
                    case .failure(_):
                        placeholderImage
                            .overlay(
                                Image(systemName: "arrow.circlepath")
                                    .padding()
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            )
                        
                    case .empty:
                        placeholderImage
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(Color(UIColor.systemBackground))
                            )
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    trigger += 1
                    if cat.isLiked() {
                        cat.dislike()
                    } else {
                        cat.like()
                    }
                }, label: {
                    Image(systemName: "heart")
                        .font(.title)
                        .symbolVariant(cat.isLiked() ? .fill : .circle)
                        .symbolEffect(.bounce, value: trigger)
                        .tint(cat.isLiked() ? .red : .white)
                        .shadow(radius: 2)
                })
                .padding(.horizontal, cat.isLiked() ? 3 : 4)
                .padding(.vertical, cat.isLiked() ? 6 : 4)
            }
            
            HStack {
                ForEach(cat.tags, id: \.self) { tag in
                    Button {
                        onTagSelected(tag)
                    } label: {
                        Text(tag)
                            .foregroundStyle(Color.accentColor)
                            .lineLimit(1)
                            .font(.caption.bold())
                            .padding(.vertical, 10)
                            .padding(.horizontal)
                            .background(Capsule().fill(Color.white.gradient))
                    }
                }
            }
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(Color.accentColor.gradient)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
        .padding()
    }
    
    // MARK: Subviews
    @ViewBuilder
    var placeholderImage: some View {
        Image(systemName: "cat.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundStyle(Color(UIColor.label))
            .opacity(0.8)
    }
}
