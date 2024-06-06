//
//  CatDetailViewModel.swift
//  Cats
//
//  Created by Alberto on 05/06/24.
//

import Foundation

class CatDetailViewModel: ObservableObject {
    @Published var cat: Cat
    @Published var catsByTag = [String: [Cat]]()
    @Published var imageIsLoaded = false
    @Published var trigger = 0

    init(cat: Cat) {
        self.cat = cat
    }

    func fetchCatDetails() {
        Task {
            do {
                let loadedCat = try await CatService.fetchCat(by: cat.id)
                DispatchQueue.main.async {
                    self.cat = loadedCat
                }
            } catch {
                print("Error fetching cat details: \(error.localizedDescription)")
            }
        }
    }

    func loadCats(tag: String) {
        Task {
            do {
                let skip = 0
                let limit = 5 // We only want 4 but need an extra one if the profile is duplicated
                var loadedCats = try await CatService.fetchCats(tags: [tag], skip: skip, limit: limit)
                loadedCats = loadedCats.filter { $0 != cat }
                let filteredCats = Array(loadedCats.prefix(4))
                DispatchQueue.main.async {
                    self.catsByTag[tag] = filteredCats
                }
            } catch {
                print("Error loading cats for tag \(tag): \(error.localizedDescription)")
            }
        }
    }
}
