//
//  ContentView.swift
//  Cats
//
//  Created by Alberto on 23/02/24.
//

import SwiftUI

struct ContentView: View {
    @State private var allTags: [String] = []
    @State private var selectedTags: [String] = []
    @State private var isLoadingCats = true
    @State private var isLoadingTags = true
    @State private var showingTagsSheet = false
    @State private var cats: [Cat] = []
    @State private var skip: Int = 0
    @State private var noMoreResults = false
    @State private var shouldLoadMoreCats = true
    
    private let tagsLastFetchKey = "TagsLastFetchTime"
    private let tagsKey = "CachedTags"
    private let limit: Int = 10
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(cats) { cat in
                            NavigationLink {
                                CatView(cat: cat, catImage: nil)
                            } label: {
                                CatCard(cat: cat) { tag in
                                    selectedTags = [tag]
                                    Task {
                                        isLoadingCats = true
                                        await loadCats(replace: true)
                                    }
                                }
                            }
                        }
                    }
                    
                    if !isLoadingCats && !noMoreResults {
                        LazyVStack {
                            Image(systemName: "arrow.circlepath")
                                .fontWeight(.black)
                                .padding(8)
                                .foregroundStyle(Color(UIColor.label))
                                .background(Circle().fill(.ultraThinMaterial))
                                .onAppear {
                                    if shouldLoadMoreCats {
                                        Task {
                                            await loadCats(replace: false)
                                        }
                                    }
                                    shouldLoadMoreCats = false
                                }
                        }
                    } else {
                        Color.clear
                            .onAppear {
                                Task {
                                    await loadCats(replace: false)
                                }
                            }
                    }
                }
                
                if isLoadingCats || isLoadingTags {
                    ProgressView()
                }
            }
            .navigationTitle("Cats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    TagsMenu(tags: selectedTags) { action in
                        switch action {
                        case .removeAll:
                            selectedTags = []
                        case .remove(let tag):
                            selectedTags = selectedTags.filter({ $0 != tag})
                        case .showTagsSheet:
                            showingTagsSheet = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingTagsSheet, onDismiss: {
            shouldLoadMoreCats = true
        }, content: {
            TagsView(tags: allTags, selectedTags: $selectedTags) {
                print("Date: ", Date())
                Task {
                    await loadCats(replace: true)
                }
            }
            .presentationDetents([.medium, .large])
        })
        .onAppear {
            Task {
                await loadTags()
            }
        }
    }
    
    private func loadCats(replace: Bool) async {
        Task {
            do {
                let currentSkip = replace ? 0 : skip
                let loadedCats = try await Cat.fetch(tags: selectedTags, skip: currentSkip, limit: limit)
                DispatchQueue.main.async {
                    isLoadingCats = false
                    
                    if replace {
                        cats = loadedCats
                    } else {
                        cats.append(contentsOf: loadedCats)
                    }
                    self.noMoreResults = loadedCats.count < limit
                    self.skip += loadedCats.count
                }
            } catch RequestError.invalidURL {
                print("invalid URL")
                isLoadingCats = false
            } catch RequestError.invalidResponse {
                print("invalid Error")
                isLoadingCats = false
            } catch {
                print("Unexpected error: ", error)
                isLoadingCats = false
            }
        }
    }
    
    private func loadTags() async {
        // Attempt to load cached data
        let defaults = UserDefaults.standard
        if let savedTags = defaults.object(forKey: tagsKey) as? [String],
           let lastFetch = defaults.object(forKey: tagsLastFetchKey) as? Date,
           Date().timeIntervalSince(lastFetch) < 86400 {
            self.allTags = savedTags
            self.isLoadingTags = false
        } else {
            Task {
                do {
                    try await fetchTags()
                } catch RequestError.invalidURL {
                    print("invalid URL")
                } catch RequestError.invalidResponse {
                    print("invalid Error")
                } catch {
                    print("Unexpected error: ", error)
                }
            }
        }
    }
    
    private func fetchTags() async throws {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/api/tags"
        
        guard let url = components.url else {
            throw RequestError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw RequestError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let loadedTags = try decoder.decode([String].self, from: data)
            let validTags = Array(Set(loadedTags)).filter({ !$0.isEmpty }).sorted()
            
            DispatchQueue.main.async {
                self.allTags = validTags
                self.isLoadingTags = false
            }
        } catch {
            throw error
        }
    }
}

#Preview {
    ContentView()
}
