//
//  FavoriteCatCard.swift
//  Cats
//
//  Created by Alberto on 05/06/24.
//

import SwiftUI

struct FavoriteCatCard: View {
    @State var trigger = 0
    @State var imageIsLoaded = false
    private let itemWidth: CGFloat = 150
    
    let cat: Cat
    
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
    FavoriteCatCard(cat: Cat(id: "5llbIzGS52clSUik", size: 1.0, tags: ["white", "tag2"], mimetype: "image/gif", createdAt: nil, editedAt: nil))
}
