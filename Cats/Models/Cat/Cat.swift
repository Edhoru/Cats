//
//  Cat.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation
import SwiftData

@Model
class Cat: Codable, Identifiable, Hashable, Equatable {
    let id: String
    let size: Double?
    let tags: [String]
    let mimetype: String
    let createdAt: Date?
    let editedAt: Date?
    
    static func ==(lhs: Cat, rhs: Cat) -> Bool {
        return lhs.id == rhs.id
    }

    init(id: String, size: Double? = nil, tags: [String] = [], mimetype: String, createdAt: Date? = nil, editedAt: Date? = nil) {
        self.id = id
        self.size = size
        self.tags = tags
        self.mimetype = mimetype
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case tags
        case mimetype
        case createdAt
        case editedAt
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.size = try container.decodeIfPresent(Double.self, forKey: .size)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.mimetype = try container.decode(String.self, forKey: .mimetype)
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        self.editedAt = try container.decodeIfPresent(Date.self, forKey: .editedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encode(tags, forKey: .tags)
        try container.encode(mimetype, forKey: .mimetype)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(editedAt, forKey: .editedAt)
    }
    
    var multipleTags: [String] {
        return tags + tags + tags
    }

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
