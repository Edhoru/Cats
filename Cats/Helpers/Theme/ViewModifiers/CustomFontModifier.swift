//
//  CustomFontModifier.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    
    enum DefaultFontSize: CGFloat {
        case largeTitle = 34
        case title = 28
        case title2 = 22
        case title3 = 20
        case body = 17
        case callout = 16
        case subheadline = 15
        case footnote = 13
        case caption = 12
        case caption2 = 11
    }
    
    let fontManager = FontManager()
    let fontSize: DefaultFontSize?
    
    func body(content: Content) -> some View {
        content
            .font(fontManager.selectedFont(fontSize?.rawValue ?? UIFont.systemFontSize))
    }
}

extension View {
    func customFont(_ size: CustomFontModifier.DefaultFontSize? = nil) -> some View {
        self.modifier(CustomFontModifier(fontSize: size))
    }
}
