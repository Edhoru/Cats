//
//  Cat+Likes.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

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
