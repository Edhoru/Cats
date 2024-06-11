//
//  Cat+Likes.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation
import SwiftData
import SwiftUI

extension Cat {
    
    static var currentFavorites: [Cat] = []
    
    static func getFavoritedCats(modelContext: ModelContext, fromNotification: Bool) -> [Cat] {
        let fetchDescriptor = FetchDescriptor<Cat>(sortBy: [SortDescriptor(\Cat.id)])
        do {
            let favoritedCats = try modelContext.fetch(fetchDescriptor)
            
            let differences = favoritedCats.difference(from: currentFavorites)
                for change in differences {
                    switch change {
                    case .remove(_, let cat, _):
                        NotificationCenter.default.post(name: .favoriteUpdated(with: cat.safeId), object: nil)
                    case .insert(_, let cat, _):
                        NotificationCenter.default.post(name: .favoriteUpdated(with: cat.safeId), object: nil)
                    }
                }
            
            currentFavorites = favoritedCats
            return Array(Set(favoritedCats))
        } catch {
            print(error)
            return []
        }
    }
    
    func isFavorited(modelContext: ModelContext) -> Bool {
        return Self.getFavoritedCats(modelContext: modelContext, fromNotification: false).contains { $0.id == self.id }
    }
    
    func favorite(modelContext: ModelContext) {
        do {
            modelContext.insert(self)
            try modelContext.save()
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        } catch {
            print(error)
        }
    }
    
    func unfavorite(modelContext: ModelContext) {
        let fetchDescriptor = FetchDescriptor<Cat>(
            predicate: #Predicate { $0.id == self.id },
            sortBy: [SortDescriptor(\Cat.id)]
        )
        do {
            if let existingCat = try modelContext.fetch(fetchDescriptor).first {
                modelContext.delete(existingCat)
                try modelContext.save()
                NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
            }
        } catch {
            print(error)
        }
    }
}

extension Notification.Name {
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
    static func favoriteUpdated(with id: String) -> Notification.Name {
        return Notification.Name("favoriteUpdated-\(id)")
    }
}
