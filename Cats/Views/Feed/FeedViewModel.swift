//
//  FeedViewModel.swift
//  Cats
//
//  Created by Alberto on 04/06/24.
//

import Combine
import SwiftUI

class FeedViewModel: ObservableObject {
    @Published var allTags: [String] = []
    @Published var selectedTags: [String] = []
    @Published var isLoadingCats = false
    @Published var isLoadingTags = false
    @Published var showingTagsSheet = false
    @Published var cats: [Cat] = []
    @Published var skip: Int = 0
    @Published var noMoreResults = false
    @Published var shouldLoadMoreCats = true
    @Published var horizontalSafeArea: CGFloat = 0
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var firstLoadIsFinished = false
    
    private let tagsLastFetchKey = "TagsLastFetchTime"
    private let tagsKey = "CachedTags"
    private let limit: Int = 10
    private var cancellables: Set<AnyCancellable> = []
    
    init() {
        NotificationCenter.default.publisher(for: .dismissToRootWithTag)
            .compactMap { $0.userInfo?["tag"] as? String }
            .sink { [weak self] tag in
                self?.handleDismiss(with: tag)
            }
            .store(in: &cancellables)
    }
    
    private func handleDismiss(with tag: String) {
        selectedTags = [tag]
        loadCats(replace: true)
    }

    func loadCats(replace: Bool) {
        isLoadingCats = true
        let currentSkip = replace ? 0 : skip
        
        Task {
            do {
                let loadedCats = try await CatService.fetchCats(tags: selectedTags, skip: currentSkip, limit: limit)
                DispatchQueue.main.async {
                    self.isLoadingCats = false
                    self.firstLoadIsFinished = true
                    withAnimation {
                        if replace {
                            self.cats = loadedCats
                        } else {
                            self.cats.append(contentsOf: loadedCats)
                        }
                    }
                    self.noMoreResults = loadedCats.count < self.limit
                    self.shouldLoadMoreCats = true
                    self.skip += loadedCats.count
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoadingCats = false
                    self.firstLoadIsFinished = true
                    self.alertMessage = "Error loading cats: \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
    
    func loadTags() {
        isLoadingTags = true
        
        Task {
            if let savedTags = await getSavedTags() {
                DispatchQueue.main.async {
                    self.allTags = savedTags
                    self.isLoadingTags = false
                }
            } else {
                do {
                    let loadedTags = try await CatService.fetchTags()
                    let validTags = Array(Set(loadedTags)).filter { !$0.isEmpty }.sorted()
                    DispatchQueue.main.async {
                        self.allTags = validTags
                        self.isLoadingTags = false
                        self.saveTags(validTags)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.isLoadingTags = false
                        self.alertMessage = "Error loading tags: \(error.localizedDescription)"
                        self.showAlert = true
                    }
                }
            }
        }
    }
    
    public func addSelectedTag(_ tag: String, reload: (Bool) -> Void) {
        if !selectedTags.contains(tag) {
            selectedTags.append(tag)
            reload(true)
        } else {
            reload(false)
        }
    }
    
    public func setSelectedTags(_ tags: [String]) {
        selectedTags = tags
    }
    
    private func getSavedTags() async -> [String]? {
        await MainActor.run {
            let defaults = UserDefaults.standard
            if let savedTags = defaults.array(forKey: tagsKey) as? [String],
               let lastFetch = defaults.object(forKey: tagsLastFetchKey) as? Date,
               Date().timeIntervalSince(lastFetch) < 86400 {
                return savedTags
            }
            return nil
        }
    }
    
    private func saveTags(_ tags: [String]) {
        DispatchQueue.main.async {
            let defaults = UserDefaults.standard
            defaults.set(tags, forKey: self.tagsKey)
            defaults.set(Date(), forKey: self.tagsLastFetchKey)
        }
    }
}
