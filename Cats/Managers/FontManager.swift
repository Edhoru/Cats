//
//  FontManager.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI
import Combine

class FontManager: ObservableObject {
    
    let fontKey = "kCustomFont"
    
    @Published var selectedFontName: String? {
        didSet {
            if let fontName = selectedFontName {
                UserDefaults.standard.set(fontName, forKey: fontKey)
            } else {
                UserDefaults.standard.removeObject(forKey: fontKey)
            }
        }
    }
    
    var selectedFont: Font {
        if let fontName = selectedFontName, !fontName.isEmpty {
            return .custom(fontName, size: UIFont.systemFontSize)
        } else {
            return Font(UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular))
        }
    }
    
    init() {
        self.selectedFontName = UserDefaults.standard.string(forKey: fontKey)
    }
    
    func updateFont(to fontName: String) {
        selectedFontName = fontName
    }
}
