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
    
    static func getFavoritedCats(modelContext: ModelContext) -> [Cat] {
        let fetchDescriptor = FetchDescriptor<Cat>(sortBy: [SortDescriptor(\Cat.id)])
        do {
            let favoritedCats = try modelContext.fetch(fetchDescriptor)
            return Array(Set(favoritedCats))
        } catch {
            print(error)
            return []
        }
    }
    
    func isFavorited(modelContext: ModelContext) -> Bool {
        return Self.getFavoritedCats(modelContext: modelContext).contains { $0.id == self.id }
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
}
