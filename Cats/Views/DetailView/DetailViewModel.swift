//
//  DetailViewModel.swift
//  Cats
//
//  Created by Alberto on 05/06/24.
//

import Foundation

class DetailViewModel: ObservableObject {
    @Published var cat: Cat
    @Published var catsByTag = [String: [Cat]]()
    @Published var imageIsLoaded = false
    @Published var trigger = 0
    @Published var showAlert = false
    @Published var alertMessage = ""

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
                DispatchQueue.main.async {
                    self.alertMessage = "Error fetching cat details: \(error.localizedDescription)"
                    self.showAlert = true
                }
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
                DispatchQueue.main.async {
                    self.alertMessage = "Error loading cats for tag \(tag): \(error.localizedDescription)"
                    self.showAlert = true
                }
            }
        }
    }
}
