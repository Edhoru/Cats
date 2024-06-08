//
//  Cat.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

struct Cat: Codable, Identifiable, Hashable {
    let id: String
    let size: Double?
    let tags: [String]
    let mimetype: String // We don't use an enum as there is no certainty we know all the possibilities
    let createdAt: Date?
    let editedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case tags
        case mimetype
        case createdAt
        case editedAt
    }
    
    var multipleTags: [String] {
        return tags + tags + tags
    }
    
    /// All images reduce to fit the screen
    func imageURL(width: CGFloat? = nil, height: CGFloat? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/cat/\(id)"
        
        var queryItems: [URLQueryItem] = []
        
        if let width = width {
            queryItems.append(URLQueryItem(name: "width", value: "\(width)"))
        }
        
        if let height = height {
            queryItems.append(URLQueryItem(name: "height", value: "\(height)"))
        }
        
        components.queryItems = queryItems
        
        return components.url
    }
    
    var createdAtString: String? {
        guard let createdAt = createdAt else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: createdAt)
    }
    
    var editedAtString: String? {
        guard let editedAt = editedAt else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: editedAt)
    }
}
