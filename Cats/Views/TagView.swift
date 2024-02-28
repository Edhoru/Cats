//
//  TagView.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import SwiftUI

struct TagView: View {
    let tag: String
    var foregroundColor: Color = .accentColor
    var backgroundColor: Color = .white
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag")
            Text(tag)
        }
        .foregroundStyle(foregroundColor)
        .lineLimit(1)
        .font(.caption.bold())
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(Capsule().fill(backgroundColor.gradient))
    }
}

#Preview {
    TagView(tag: "Tag 1")
}

#Preview {
    TagView(tag: "Tag Colored", foregroundColor: .white, backgroundColor: .accentColor)
}
