//
//  Cat+Data.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

extension Cat {
    
    static func fetch(skip: Int, limit: Int) async throws -> [Cat] {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/api/cats"
        components.queryItems = [
            URLQueryItem(name: "skip", value: "\(skip)"),
            URLQueryItem(name: "limit", value: "\(limit)")
        ]
        
        guard let url = components.url else {
            throw RequestError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RequestError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let loadedCats = try decoder.decode([Cat].self, from: data)
            return loadedCats
        } catch {
            throw error
        }
    }
    
}
