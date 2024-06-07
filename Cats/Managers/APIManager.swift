//
//  APIManager.swift
//  Cats
//
//  Created by Alberto on 05/06/24.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    func fetchObject<T: Decodable>(with request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
//        let json = try? JSONSerialization.jsonObject(with: data)
//        print("json: ", json)
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            decoder.dateDecodingStrategy = .formatted(formatter)
            let decodedData = try decoder.decode(T.self, from: data)
            print("decodedCat: ", decodedData)
            return decodedData
        } catch {
            print(error)
            throw APIError.decodingError(error.localizedDescription)
        }
    }
    
    func fetchData(with request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw APIError.invalidResponse
        }
        
        return data
    }
}

enum APIError: Error, LocalizedError {
    case networkError(String)
    case dataNotFound
    case decodingError(String)
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataNotFound:
            return "Data not found."
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        case .invalidResponse:
            return "Invalid response from server."
        }
    }
}
