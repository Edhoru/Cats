//
//  TagView.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import SwiftUI

struct TagView: View {
    let tag: String
    var foregroundColor: Color
    var backgroundColor: Color
    
    @EnvironmentObject var colorsManager: ColorsManager

    init(tag: String, foregroundColor: Color? = nil, backgroundColor: Color? = nil) {
        self.tag = tag
        self.foregroundColor = foregroundColor ?? ColorsManager().selectedColor(for: .accent)
        self.backgroundColor = backgroundColor ?? ColorsManager().selectedColor(for: .background)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag")
            Text(tag)
        }
        .foregroundStyle(foregroundColor)
        .lineLimit(1)
        .customFont(.caption)
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Capsule().fill(backgroundColor.gradient))
    }
}

#Preview {
    TagView(tag: "Tag 1")
        .environmentObject(ColorsManager())
}

#Preview {
    TagView(tag: "Tag Colored", foregroundColor: .white, backgroundColor: .accentColor)
        .environmentObject(ColorsManager())
}
