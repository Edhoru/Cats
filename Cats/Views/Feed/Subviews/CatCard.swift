//
//  CatCard.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import SwiftUI

#if os(iOS)
struct CatCard: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    @State var trigger = 0
    @State var imageIsLoaded = false
    
    let itemWidth: CGFloat
    
    let cat: Cat
    
    var onTagSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .topTrailing) {
                    CachedAsyncImage(url: cat.imageURL()) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: itemWidth, height: itemWidth)
                                .clipped()
                        case .failure(_):
                            placeholderImage
                                .overlay(
                                    Image(systemName: "arrow.circlepath")
                                        .padding()
                                        .foregroundStyle(Color(UIColor.systemBackground))
                                )
                                .frame(width: itemWidth, height: itemWidth)
                        case .empty:
                            placeholderImage
                                .overlay(
                                    Image(systemName: "arrow.circlepath")
                                        .padding()
                                        .foregroundStyle(Color(UIColor.systemBackground))
                                )
                                .frame(width: itemWidth, height: itemWidth)
                        @unknown default:
                            EmptyView()
                        }
                    }
                
                Button(action: {
                    trigger += 1
                    if cat.isFavorited() {
                        cat.unfavorite()
                    } else {
                        cat.favorite()
                    }
                }, label: {
                    Image(systemName: "heart")
                        .font(.title)
                        .symbolVariant(cat.isFavorited() ? .fill : .circle)
                        .symbolEffect(.bounce, value: trigger)
                        .tint(cat.isFavorited() ? .red : .white)
                        .shadow(radius: 2)
                })
                .padding(.horizontal, cat.isFavorited() ? 3 : 4)
                .padding(.vertical, cat.isFavorited() ? 6 : 4)
            }
            
            TagLayout(alignment: .center, spacing: 10) {
                ForEach(cat.tags, id: \.self) { tag in
                    TagView(tag: tag)
                        .onTapGesture {
                            onTagSelected(tag)
                        }
                }
            }
            .padding(.vertical, 10)
            .background(Color.customForeground.gradient)
            .environmentObject(colorsManager)
            .environmentObject(fontManager)
            
        }
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
    }
    
    // MARK: Subviews
    @ViewBuilder
    var placeholderImage: some View {
        Image("waiting")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(Color(UIColor.label))
            .opacity(0.8)
    }
}

#Preview {
    CatCard(itemWidth: 300, cat: Cat(id: "a", size: 1.0, tags: ["tag1", "tag2"], mimetype: "image/gif", createdAt: nil, editedAt: nil)) { _ in }
        .environmentObject(ColorsManager())
        .environmentObject(FontManager())
}
#endif
