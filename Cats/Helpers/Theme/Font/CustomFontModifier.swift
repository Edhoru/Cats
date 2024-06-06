//
//  CustomFontModifier.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    let fontManager = FontManager()
    
    func body(content: Content) -> some View {
        content
            .font(fontManager.selectedFont)
    }
}

extension View {
    func customFont() -> some View {
        self.modifier(CustomFontModifier())
    }
}


#Preview {
    let fontManager = FontManager()
    
    return VStack {
        Text("Custom font: \(fontManager.selectedFontName)")
            .customFont()
        
        FontListView()
    }
    .environmentObject(fontManager)
}
