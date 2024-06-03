//
//  ErrorManager.swift
//  Cats
//
//  Created by Alberto on 28/05/24.
//

import Foundation

class ErrorManager: ObservableObject {
    static let shared = ErrorManager()
    
    @Published var errorMessage: String? = nil
    
    private init() {}
    
    func handleError(_ error: Error) {
        if let apiError = error as? APIError {
            errorMessage = apiError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
}
