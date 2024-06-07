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
        
        // The api may return the same cat twice, we filter here to avoid issues wit hswiftui layoutlet loadedCats: [Cat] = try await APIManager.shared.fetchObject(with: request)
        let loadedCats: [Cat] = try await APIManager.shared.fetchObject(with: request)
        var seenIds = Set<String>()
        let uniqueCats = loadedCats.filter { cat in
            if seenIds.contains(cat.id) {
                return false
            } else {
                seenIds.insert(cat.id)
                return true
            }
        }
        
        return uniqueCats
    }
    
    static func fetchCat(by id: String) async throws -> Cat {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/cat/\(id)"
        
        guard let url = components.url else {
            throw APIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        return try await APIManager.shared.fetchObject(with: request)
    }
    
    static func fetchRandomCat() async throws -> Data {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/cat"
        components.queryItems = [
            URLQueryItem(name: "position", value: "center")
        ]
        
        guard let url = components.url else {
            throw APIError.networkError("Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.setValue("image/*", forHTTPHeaderField: "accept")
        
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
        
        return try await APIManager.shared.fetchObject(with: request)
    }
}
