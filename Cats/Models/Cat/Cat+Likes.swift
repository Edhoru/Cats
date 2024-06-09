//
//  Cat+Likes.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

extension Cat {
    
    private static let favoritedCatsKey = "catsFavorited"
    public static let favoritesUpdatedNotification = Notification.Name("favoritesUpdated")
    
    private static func updateFavoritedCats(updateHandler: (inout [Cat]) -> Void) {
        var favoritedCats = getFavoritedCats()
        updateHandler(&favoritedCats)
        
        if let encoded = try? JSONEncoder().encode(favoritedCats) {
            UserDefaults.standard.set(encoded, forKey: favoritedCatsKey)
        }
        
        NotificationCenter.default.post(name: favoritesUpdatedNotification, object: nil)
    }
    
    static func getFavoritedCats() -> [Cat] {
        if let data = UserDefaults.standard.data(forKey: favoritedCatsKey) {
            do {
                let cats = try JSONDecoder().decode([Cat].self, from: data)
                let ordered = Array(Set(cats))
                return ordered
            } catch {
                print(error)
            }
        }
        return []
    }
    
    func isFavorited() -> Bool {
        if Self.getFavoritedCats().map({ $0.id }).contains(self.id) {
            return true
        } else {
            return false
        }
    }
    
    func favorite() {
        Self.updateFavoritedCats { favoritedCats in
            favoritedCats.append(self)
        }
    }
    
    func unfavorite() {
        Self.updateFavoritedCats { favoritedCats in
            favoritedCats.removeAll { $0 == self }
        }
    }
    
}

