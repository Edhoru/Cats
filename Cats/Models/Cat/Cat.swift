//
//  Cat.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

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
