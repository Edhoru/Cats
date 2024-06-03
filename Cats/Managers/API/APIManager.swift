//
//  APIManager.swift
//  Cats
//
//  Created by Alberto on 28/05/24.
//

import Foundation

class APIManager {
    static let shared = APIManager()
    
    private init() {}
    
    func fetchData<T: Decodable>(from url: URL, completion: @escaping (Result<T, APIError>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error.localizedDescription)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.dataNotFound))
                return
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError(error.localizedDescription)))
            }
        }
        task.resume()
    }
}

enum APIError: Error, LocalizedError {
    case networkError(String)
    case dataNotFound
    case decodingError(String)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .dataNotFound:
            return "Data not found."
        case .decodingError(let message):
            return "Decoding Error: \(message)"
        }
    }
}
