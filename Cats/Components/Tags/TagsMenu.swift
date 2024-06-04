//
//  TagsMenu.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import SwiftUI

struct TagsMenu: View {
    
    enum Action {
        case removeAll
        case remove(String)
        case showTagsSheet
    }
    
    
    var tags: [String]
    var action: (Action) -> Void
    
    var body: some View {
        Menu {
            if (tags.count > 1) {
                Button{
                    action(.removeAll)
                } label: {
                    Label("Remove All Tags", systemImage: "trash.fill")
                }
            }
            
            Button {
                action(.showTagsSheet)
            } label: {
                Label("See All Tags", systemImage: "eye")
            }
            
            Divider()
            
            ForEach(tags, id: \.self) { tag in
                Button{
                    action(.remove(tag))
                } label: {
                    Label(tag, systemImage: "trash")
                }
            }
        } label: {
            Image(systemName: "tag.fill")
                .overlay(alignment: .topLeading) {
                    if tags.count > 0 {
                        let count = tags.count < 10 ? "\(tags.count)" : "+"
                        Text(count)
                            .frame(width: 8, height: 8)
                            .font(.caption2.bold())
                            .padding(6)
                            .background(
                                Circle()
                                    .fill(Color.red)
                                    .strokeBorder(Color.white, lineWidth: 1)
                            )
                            .foregroundColor(.white)
                            .offset(x: -8, y: -8)
                    }
                }
        }
    }
}

#Preview {
    TagsMenu(tags: ["Tag1", "Tag2"]) { _ in }
}
