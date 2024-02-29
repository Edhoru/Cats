//
//  CatCard.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import SwiftUI

struct CatCard: View {
    @State var trigger = 0
    @State var imageIsLoaded = false
    
    let cat: Cat
    
    var onTagSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 2) {
            ZStack(alignment: .topTrailing) {
                CachedAsyncImage(url: cat.imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity)
                            .frame(maxHeight: 400)
                    case .failure(_):
                        placeholderImage
                            .overlay(
                                Image(systemName: "arrow.circlepath")
                                    .padding()
                                    .foregroundStyle(Color(UIColor.systemBackground))
                            )
                        
                    case .empty:
                        placeholderImage
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .tint(Color(UIColor.systemBackground))
                            )
                        
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    trigger += 1
                    if cat.isLiked() {
                        cat.dislike()
                    } else {
                        cat.like()
                    }
                }, label: {
                    Image(systemName: "heart")
                        .font(.title)
                        .symbolVariant(cat.isLiked() ? .fill : .circle)
                        .symbolEffect(.bounce, value: trigger)
                        .tint(cat.isLiked() ? .red : .white)
                        .shadow(radius: 2)
                })
                .padding(.horizontal, cat.isLiked() ? 3 : 4)
                .padding(.vertical, cat.isLiked() ? 6 : 4)
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
            .frame(maxWidth: .infinity)
            .background(Color.accentColor.gradient)
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3)
        .padding()
    }
    
    // MARK: Subviews
    @ViewBuilder
    var placeholderImage: some View {
        Image(systemName: "cat.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundStyle(Color(UIColor.label))
            .opacity(0.8)
    }
}

#Preview {
    CatCard(cat: Cat(id: "a", size: 1.0, tags: ["tag1", "tag2"], mimetype: "image/gif")) { _ in }
}
