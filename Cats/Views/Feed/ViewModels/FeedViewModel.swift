//
//  FeedViewModel.swift
//  Cats
//
//  Created by Alberto on 04/06/24.
//

import Foundation

class FeedViewModel: ObservableObject {
    @Published var allTags: [String] = []
    @Published var selectedTags: [String] = []
    @Published var isLoadingCats = true
    @Published var isLoadingTags = true
    @Published var showingTagsSheet = false
    @Published var cats: [Cat] = []
    @Published var skip: Int = 0
    @Published var noMoreResults = false
    @Published var shouldLoadMoreCats = true
    
    private let tagsLastFetchKey = "TagsLastFetchTime"
    private let tagsKey = "CachedTags"
    private let limit: Int = 10
    
    func loadCats(replace: Bool) async {
        do {
            let currentSkip = replace ? 0 : skip
            let loadedCats = try await Cat.fetch(tags: selectedTags, skip: currentSkip, limit: limit)
            DispatchQueue.main.async {
                self.isLoadingCats = false
                
                if replace {
                    self.cats = loadedCats
                } else {
                    self.cats.append(contentsOf: loadedCats)
                }
                self.noMoreResults = loadedCats.count < self.limit
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
    
    func loadTags() async {
        let defaults = UserDefaults.standard
        if let savedTags = defaults.object(forKey: tagsKey) as? [String],
           let lastFetch = defaults.object(forKey: tagsLastFetchKey) as? Date,
           Date().timeIntervalSince(lastFetch) < 86400 {
            self.allTags = savedTags
            self.isLoadingTags = false
        } else {
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
