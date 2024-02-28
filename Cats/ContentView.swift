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
    let mimetype: String // We don't use an enum as there is no certainty we know all the posibilities
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case tags
        case mimetype
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
    @State var requestSkip: Int = 0
    @State var requestLimit: Int = 10
    @State var allTags: [String] = ["SampleTag1", "SampleTag2"] {
        didSet {
            print("didSet: ", allTags)
        }
    }
    @State var selectedTags: [String] = [] // Example active tag
    
    @State private var selectedCat: Cat?
    @State private var showTagSearch: Bool = false
    
    @State private var showFilters: Bool = false
    
    private let adaptiveColumns = [
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 2) {
                    ForEach(cats) { cat in
                        NavigationLink {
                            Text("cat")
                        } label: {
                            CatCard(cat: cat) { tag in
                                if !selectedTags.contains(tag) {
                                    selectedTags.append(tag)
                                }
                                selectedTags.append(tag)
                            }
                        }
                    }
                }
                
                LazyVStack {
                    Image(systemName: "arrow.circlepath")
                        .fontWeight(.black)
                        .padding(8)
                        .foregroundStyle(Color(UIColor.label))
                        .background(Circle().fill(.ultraThinMaterial))
                        .onAppear(perform: fetchCats)
                }
            }
            .fullScreenCover(isPresented: $showFilters) {
                if allTags.isEmpty {
                    Text("Empty")
                } else {
                    TagsView(allTags: allTags, activeTags: selectedTags)
                }
            }
            .navigationTitle("Cats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                Menu {
                    if (selectedTags.count > 1) {
                        Button{
                            removeAllTags()
                        } label: {
                            Label("Remove All Tags", systemImage: "xmark")
                        }
                    }
                    Button{
                        seeAllTags()
                    } label: {
                        Label("See All Tags", systemImage: "eye")
                    }
                    
                    Divider()
                    
                    ForEach(selectedTags, id: \.self) { tag in
                        Button{
                            remove(tag: tag)
                        } label: {
                            Label(tag, systemImage: "tag")
                        }
                    }
                }  label: {
                    Image(systemName: "tag.fill")
                }
            }
            .task {
                fetchTags()
            }
        }
    }
    
    
    func removeAllTags() {
        selectedTags.removeAll()
    }
    
    func seeAllTags() {
        showFilters = true
    }
    
    func remove(tag: String) {
        selectedTags = selectedTags.filter({ $0 != tag})
    }
    
    private func fetchCats() {
//        Task {
//            do {
//                try await getCats()
//            } catch CatError.invalidURL {
//                print("invalid URL")
//            } catch CatError.invalidResponse {
//                print("invalid Error")
//            } catch {
//                print("Unexpected error: ", error)
//            }
//        }
    }
    
    func getCats() async throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/api/cats"
        components.queryItems = [
            URLQueryItem(name: "skip", value: "\(requestSkip)"),
            URLQueryItem(name: "limit", value: "\(requestLimit)")
        ]
        
        guard let url = components.url else {
            throw CatError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw CatError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let loadedCats = try decoder.decode([Cat].self, from: data)
            self.cats.append(contentsOf: loadedCats)
            requestSkip += requestLimit
        } catch {
            throw error
        }
    }
    
    private func fetchTags() {
        Task {
            try await getTags()
        }
    }
    
    func getTags() async throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/api/tags"
        
        guard let url = components.url else {
            throw CatError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw CatError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let loadedTags = try decoder.decode([String].self, from: data)
            let validTags = Array(Set(loadedTags)).filter({ $0 != "" })
            self.allTags = validTags
            print("self.alltags: ", self.allTags)
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
    @State var imageIsLoaded = false
    
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
            
            TagLayout(alignment: .center, spacing: 10) {
                ForEach(cat.tags, id: \.self) { tag in
                    TagView(tag: tag)
                        .onTapGesture {
                            onTagSelected(tag)
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

struct TagView: View {
    let tag: String
    var foregroundColor: Color = .accentColor
    var backgroundColor: Color = .white
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag")
            Text(tag)
        }
        .foregroundStyle(foregroundColor)
        .lineLimit(1)
        .font(.caption.bold())
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Capsule().fill(backgroundColor.gradient))
    }
}


struct TagLayout: Layout {
    /// Layout Properties
    var alignment: Alignment = .center
    /// Both Horizontal & Vertical
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = (proposal.width ?? 0)
        var height: CGFloat = 0
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for (index, row) in rows.enumerated() {
            if index == (rows.count - 1) {
                height += row.maxHeight(proposal)
            } else {
                height += row.maxHeight(proposal) + spacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            /// Changing origin X based on Alignments
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                
                if view == row.last {
                    /// No Spacing
                    return partialResult + width
                }
                /// With Spacing
                return partialResult + width + spacing
            })
            
            let center = (trailing + leading) / 2
            
            /// Resetting Origin X to zero for Each row
            origin.x = (alignment == .leading ? leading :
                        alignment == .trailing ? trailing : center)
            
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                /// Update Origin
                origin.x += (viewSize.width + spacing)
            }
            
            /// Updating Origin Y
            origin.y += (row.maxHeight(proposal) + spacing)
        }
    }
    
    /// Generate Rows based on Available size
    func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        /// Origin
        var origin = CGRect.zero.origin
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            if (origin.x + viewSize.width + spacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                /// Resetting X Origin since it needs to start from left to right
                origin.x = 0
                row.append(view)
                /// Update Origin X
                origin.x += (viewSize.width + spacing)
            } else {
                /// Adding item to same row
                row.append(view)
                /// Update Origin X
                origin.x += (viewSize.width + spacing)
            }
        }
        
        /// Checking for any exhaust row
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
    }
    
}


extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
