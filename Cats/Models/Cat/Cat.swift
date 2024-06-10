//
//  Cat.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation
import SwiftData

@Model
class Cat: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case size
        case tags
        case mimetype
        case createdAt
        case editedAt
    }
    
    internal var id: String?
    var size: Double?
    private var tags: [String]?
    var mimetype: String?
    var createdAt: Date?
    var editedAt: Date?
    
    init(id: String = UUID().uuidString, size: Double? = nil, tags: [String] = [], mimetype: String = "*/*", createdAt: Date? = nil, editedAt: Date? = nil) {
        self.id = id
        self.size = size
        self.tags = tags
        self.mimetype = mimetype
        self.createdAt = createdAt
        self.editedAt = editedAt
    }
    
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        size = try container.decodeIfPresent(Double.self, forKey: .size)
        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        mimetype = try container.decodeIfPresent(String.self, forKey: .mimetype)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        editedAt = try container.decodeIfPresent(Date.self, forKey: .editedAt)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(size, forKey: .size)
        try container.encodeIfPresent(tags, forKey: .tags)
        try container.encodeIfPresent(mimetype, forKey: .mimetype)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(editedAt, forKey: .editedAt)
    }
    
    var safeId: String {
        get {
            id  ?? UUID().uuidString
        }
    }
    
    var safeTags: [String] {
        get {
            tags ?? []
        }
    }

    func imageURL(width: CGFloat? = nil, height: CGFloat? = nil) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        var pathString = "/cat"
        if let safeId = id {
            pathString = pathString.appending("/\(safeId)")
        }
        components.path = pathString
        
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
