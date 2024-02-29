//
//  CatView.swift
//  Cats
//
//  Created by Alberto on 29/02/24.
//

import SwiftUI

struct CatView: View {
    @State var trigger = 0
    @State var imageIsLoaded = false
    @State private var catsByTag = [String: [Cat]]()
    
    let cat: Cat
    let catImage: Image?
    
    var body: some View {
        List {
            ZStack(alignment: .topTrailing) {
                if let image = catImage {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 300)
                        .clipped()
                } else {
                    CachedAsyncImage(url: cat.imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
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
                }
                
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
                        .foregroundStyle(cat.isLiked() ? .red : .white)
                        .shadow(radius: 2)
                })
                .padding(.horizontal, cat.isLiked() ? 3 : 4)
                .padding(.vertical, cat.isLiked() ? 6 : 4)
            }
            .listRowInsets(EdgeInsets())
            
            ForEach(cat.tags, id: \.self) { tag in
                Section {
                    section(for: tag)
                } header: {
                    HStack {
                        Text(tag)
                            .font(.title.bold())
                            .textCase(.uppercase)
                        
                        Spacer()
                        
                        if !(catsByTag[tag]?.isEmpty ?? true) {
                            NavigationLink {
                                ContentView()
                            } label: {
                                Text("Show more")
                            }
                        }
                    }
                }
                .onAppear {
                    loadCats(tag: tag)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color(UIColor.secondarySystemBackground))
        )
        .listStyle(.plain)
    }
    
    @ViewBuilder
    private func section(for tag: String) -> some View {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(catsByTag[tag] ?? [], id: \.self) { cat in
                            NavigationLink {
                                CatView(cat: cat, catImage: nil)
                            } label: {
                                    CachedAsyncImage(url: cat.imageURL) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 200)
                                            .containerRelativeFrame(.horizontal)
                                            .clipShape(.rect(cornerRadius: 16))
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
                            }
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(20, for: .scrollContent)
                .listRowInsets(EdgeInsets())
        }
    
    private func showCats(with tag: String) {
        print("show \(tag)")
    }
    
    private func loadCats(tag: String) {
        Task {
            do {
                let skip = 0
                let limit = 10 /// We only want 9 but need an extra one if the profile is duplicated
                var loadedCats = try await Cat.fetch(tags: [tag],
                                                     skip: skip,
                                                     limit: limit)
                /// Remove the cat from the profile
                loadedCats = loadedCats.filter({ $0 != cat })
                self.catsByTag[tag] = Array(loadedCats.prefix(9))
            } catch RequestError.invalidURL {
                print("invalid URL")
            } catch RequestError.invalidResponse {
                print("invalid Error")
            } catch {
                print("Unexpected error: ", error)
            }
        }
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
    NavigationStack {
        CatView(cat: Cat(id: "a", size: 1.0, tags: ["white", "tag2"], mimetype: "image/gif"),
                catImage: Image(systemName: "cat"))
    }
}
