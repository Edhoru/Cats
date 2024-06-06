//
//  FontListView.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

struct FontListView: View {
    @EnvironmentObject var fontManager: FontManager
    
    let fonts = getAllFonts()
    
    var body: some View {
        List(fonts, id: \.self) { font in
            Button {
                withAnimation {
                    fontManager.updateFont(to: font)
                }
            } label: {
                Text(font)
                    .font(.custom(font, size: 16))
            }
            .buttonStyle(.plain)
        }
        .navigationTitle("Available Fonts")
    }
    
    static private func getAllFonts() -> [String] {
        var fonts: [String] = []
        for family in UIFont.familyNames {
            let names = UIFont.fontNames(forFamilyName: family)
            fonts.append(contentsOf: names)
        }
        return fonts
    }
    
}

#Preview {
    FontListView()
}
