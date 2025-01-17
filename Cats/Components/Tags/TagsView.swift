//
//  TagsView.swift
//  Cats
//
//  Created by Alberto on 26/02/24.
//

import SwiftUI

struct TagsView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    @Environment(\.dismiss) var dismiss
    
    @Namespace private var animation
    
    var tags: [String]
    @Binding var selectedTags: [String]
    
    private var unusedTags: [String] {
            tags.filter { !selectedTags.contains($0) }
        }
    
    var updateSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(selectedTags, id: \.self) { tag in
                        TagView(tag: tag, foregroundColor: .white, backgroundColor: colorsManager.selectedColor(for: .accent))
                            .matchedGeometryEffect(id: tag, in: animation)
                            .onTapGesture {
                                withAnimation {
                                    selectedTags.removeAll(where: { $0 == tag })
                                }
                            }
                            .environmentObject(colorsManager)
                            .environmentObject(fontManager)
                    }
                }
                .padding(8)
            }
            .frame(height: 60)
            .padding(.top)
            .scrollIndicators(.hidden)
            .zIndex(1.0)
            
            /// Show unused tags
            ScrollView {
                TagLayout(alignment: .center, spacing: 10) {
                    ForEach(unusedTags, id: \.self) { tag in
                        TagView(tag: tag)
                            .matchedGeometryEffect(id: tag, in: animation)
                            .onTapGesture {
                                withAnimation {
                                    selectedTags.append(tag)
                                    selectedTags.sort()
                                }
                            }
                            .environmentObject(colorsManager)
                            .environmentObject(fontManager)
                    }
                }
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
            }
            .zIndex(0.0)
            
            Button {
                updateSearch()
                dismiss()
            } label: {
                Text("Update Search")
                    .customFont()
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
            .tint(colorsManager.selectedColor(for: .accent))
            .padding()
        }
    }
}

#Preview {
    let intArray: [Int] = Array(0...20)
    return TagsView(tags: intArray.map({ "\($0 * 15)"}), selectedTags: .constant(["90"])) {}
        .environmentObject(FontManager())
        .environmentObject(ColorsManager())
}
