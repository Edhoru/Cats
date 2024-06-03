//
//  Cat+Data.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import Foundation

extension Cat {
    
    static func fetch(tags: [String], skip: Int, limit: Int) async throws -> [Cat] {
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
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RequestError.invalidResponse
        }
        
//        print("url: ", url)
//        print("response: ", response)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let json = try JSONSerialization.jsonObject(with: data)
            print("json: ", json)
            
            
            let loadedCats = try decoder.decode([Cat].self, from: data)
            return loadedCats
        } catch {
            throw error
        }
    }
    
    static func fetch(id: String) async throws -> Cat? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "cataas.com"
        components.path = "/cat/\(id)"
        
        guard let url = components.url else {
            throw RequestError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print("url: ", url)
        print("response: ", response)
        print("data: ", data)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw RequestError.invalidResponse
        }
        
        guard !data.isEmpty else {
            throw RequestError.invalidResponse
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            print("json cat: ", json)
        } catch {
            print("json error: ", error)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
            
            let catDetails = try decoder.decode(Cat.self, from: data)
            print("catDetails: ", catDetails)
            return catDetails
        } catch {
            throw error
        }
    }
    
}
