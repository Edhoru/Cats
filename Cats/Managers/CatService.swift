//
//  Cat+Data.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

class CatService {
    
    static func fetchCats(tags: [String], skip: Int, limit: Int) async throws -> [Cat] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/api/cats"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "skip", value: "\(skip)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        if !tags.isEmpty {
            let tagsString = tags.joined(separator: ",")
            queryItems.append(URLQueryItem(name: "tags", value: tagsString))
        }
        
        components.queryItems = queryItems
        
        guard let url = components.url else {
            throw APIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        return try await APIManager.shared.fetchData(with: request)
    }
    
    static func fetchCat(by id: String) async throws -> Cat {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "catfaas.com"
        components.path = "/cat/\(id)"
        
        guard let url = components.url else {
            throw APIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        return try await APIManager.shared.fetchData(with: request)
    }
    
    static func fetchTags() async throws -> [String] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/api/tags"
        
        guard let url = components.url else {
            throw APIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        return try await APIManager.shared.fetchData(with: request)
    }
}
