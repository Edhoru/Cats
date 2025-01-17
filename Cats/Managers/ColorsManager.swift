//
//  ColorsManager.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

class ColorsManager: ObservableObject {
    
    struct ColorObject {
        let red: Double
        let green: Double
        let blue: Double
        let alpha: Double
        
        init(red: Double, green: Double, blue: Double, alpha: Double) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
        
        init(dictionary: [String: Double]) {
            self.red = dictionary["red"] ?? 0
            self.green = dictionary["green"] ?? 0
            self.blue = dictionary["blue"] ?? 0
            self.alpha = dictionary["alpha"] ?? 0
        }
        
        func toDictionary() -> [String: Double] {
            return ["red": red,
                    "green": green,
                    "blue": blue,
                    "alpha": alpha]
        }
    }
    
    enum Usage: String {
        case accent
        case background
    }
    
    private let accentColorKey = "kCustomAccentColor"
    private let backgroundColorKey = "kCustomBackgroundColor"
    
    @Published var selectedAccentColorValues: [String: Double]? {
        didSet {
            if let values = selectedAccentColorValues {
                UserDefaults.standard.set(values, forKey: accentColorKey)
            } else {
                UserDefaults.standard.removeObject(forKey: accentColorKey)
            }
        }
    }
    
    @Published var selectedBackgroundColorValues: [String: Double]? {
        didSet {
            if let values = selectedBackgroundColorValues {
                UserDefaults.standard.set(values, forKey: backgroundColorKey)
            } else {
                UserDefaults.standard.removeObject(forKey: backgroundColorKey)
            }
        }
    }
    
    init() {
        self.selectedAccentColorValues = UserDefaults.standard.dictionary(forKey: accentColorKey) as? [String: Double]
        self.selectedBackgroundColorValues = UserDefaults.standard.dictionary(forKey: backgroundColorKey) as? [String: Double]
    }
    
    func selectedColor(for usage: Usage) -> Color {
        switch usage {
        case .accent:
            if let values = selectedAccentColorValues {
                let colorObject = ColorObject(dictionary: values)
                return Color(red: colorObject.red, green: colorObject.green, blue: colorObject.blue, opacity: colorObject.alpha)
            } else {
                return Color.customForeground
            }
        case .background:
            if let values = selectedBackgroundColorValues {
                let colorObject = ColorObject(dictionary: values)
                return Color(red: colorObject.red, green: colorObject.green, blue: colorObject.blue, opacity: colorObject.alpha)
            } else {
                return Color.customBackground
            }
        }
    }
    
    func updateColor(to color: Color, usage: Usage) {
        guard let components = color.cgColor?.components, components.count >= 4 else {
            return
        }
        
        let colorObject = ColorObject(red: Double(components[0]), green: Double(components[1]), blue: Double(components[2]), alpha: Double(components[3]))
        
        switch usage {
        case .accent:
            selectedAccentColorValues = colorObject.toDictionary()
        case .background:
            selectedBackgroundColorValues = colorObject.toDictionary()
        }
    }
    
    func reset() {
        withAnimation {
            selectedAccentColorValues = nil
            selectedBackgroundColorValues = nil
        }
    }
}
