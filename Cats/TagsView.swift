//
//  TagsView.swift
//  Cats
//
//  Created by Alberto on 26/02/24.
//

import SwiftUI

struct TagsView: View {
    @Namespace private var animation
    
    @Binding var allTags: [String]
    @Binding var activeTags: [String]
    @State private var inactiveTags: [String]
    
    init(allTags: [String], activeTags: [String]) {
        _allTags = allTags
        self.activeTags = []
        self.inactiveTags = []
        
        
//        self.allTags = allTags
//        self.activeTags = activeTags
//        _inactiveTags = State(initialValue: allTags.filter({ !activeTags.contains($0) }).sorted())
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(activeTags, id: \.self) { tag in
                        TagView(tag: tag, foregroundColor: .white, backgroundColor: .red)
                            .matchedGeometryEffect(id: tag, in: animation)
                            .onTapGesture {
                                withAnimation {
                                    activeTags.removeAll(where: { $0 == tag })
                                    inactiveTags.append(tag)
                                    inactiveTags.sort() // Sort inactiveTags alphabetically
                                }
                            }
                    }
                }
                .padding(8)
            }
            .scrollIndicators(.hidden)
            .zIndex(1.0)
            
            ScrollView {
                TagLayout(alignment: .center, spacing: 10) {
                    ForEach(inactiveTags, id: \.self) { tag in
                        TagView(tag: tag)
                            .matchedGeometryEffect(id: tag, in: animation)
                            .onTapGesture {
                                withAnimation {
                                    inactiveTags.removeAll(where: { $0 == tag })
                                    activeTags.append(tag)
                                    activeTags.sort() // Sort activeTags alphabetically
                                }
                            }
                    }
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
            }
            .zIndex(0.0)
            
            Button {
                // Action for the button
            } label: {
                Text("Update Search")
                    .frame(width: .infinity, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

#Preview {
    let intArray: [Int] = Array(0...20)
    return TagsView(allTags: intArray.map({ "\($0 * 15)"}), activeTags: ["5", "13"])
}
