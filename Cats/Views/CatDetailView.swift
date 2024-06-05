//
//  CatView.swift
//  Cats
//
//  Created by Alberto on 29/02/24.
//

import SwiftUI

struct CatDetailView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    @State var trigger = 0
    @State var imageIsLoaded = false
    @State private var catsByTag = [String: [Cat]]()
    @State var cat: Cat
    
    let catImage: Image?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.background.gradient)
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        if let image = catImage {
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(maxHeight: 300)
                                .clipped()
                        } else {
                            CachedAsyncImage(url: cat.imageURL()) { phase in
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
                                .foregroundStyle(cat.isFavorited() ? .red : .white)
                                .shadow(radius: 2)
                        })
                        .padding(.horizontal, cat.isFavorited() ? 3 : 4)
                        .padding(.vertical, cat.isFavorited() ? 6 : 4)
                    }
                    .listRowInsets(EdgeInsets())
                    
                    datesContainerView
                    
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
                                        FeedView()
                                    } label: {
                                        Text("Show more")
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        .onAppear {
                            loadCats(tag: tag)
                        }
                    }
                }}
            .frame(maxWidth: .infinity)
            .listStyle(.plain)
            .onAppear {
                Task {
                    do {
                        if let loaded = try await Cat.fetch(id: cat.id) {
                            cat = loaded
                        }
                    } catch {
                        print("error: ", error)
                    }
                }
        }
        }
    }
    
    @ViewBuilder
    private func section(for tag: String) -> some View {
        if let cats = catsByTag[tag] {
            if cats.isEmpty {
                Text("There are no more results for \"\(tag)\"")
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .frame(height: 50)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(catsByTag[tag] ?? [], id: \.self) { cat in
                            NavigationLink {
                                CatDetailView(cat: cat, catImage: nil)
                            } label: {
                                CachedAsyncImage(url: cat.imageURL()) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 200, height: 200)
                                            .containerRelativeFrame(.horizontal)
                                            .clipShape(.rect(cornerRadius: 16))
                                            .background(Color.secondary)
                                            .clipShape(Circle())
                                    case .failure(_):
                                        placeholderImage
                                            .overlay(
                                                Image(systemName: "arrow.circlepath")
                                                    .padding()
                                                    .foregroundStyle(Color(UIColor.systemBackground))
                                            )
                                            .frame(width: 200, height: 200)
                                    case .empty:
                                        placeholderImage
                                            .overlay(
                                                ProgressView()
                                                    .progressViewStyle(CircularProgressViewStyle())
                                                    .tint(Color(UIColor.systemBackground))
                                            )
                                            .frame(width: 200, height: 200)
                                        
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            }
                            .frame(width: 200, height: 200)
                        }
                    }
                    .scrollTargetLayout()
                }
                .scrollTargetBehavior(.viewAligned)
                .contentMargins(20, for: .scrollContent)
                .listRowInsets(EdgeInsets())
            }
        } else {
            ProgressView()
        }
    }
    
    @ViewBuilder
    var datesContainerView: some View {
        if horizontalSizeClass == .compact {
            VStack(spacing: 12) {
                datesView
            }
            .padding()
        } else {
            HStack {
                datesView
            }
            .padding()
        }
    }
    
    @ViewBuilder
    var datesView: some View {
            if let createdAt = cat.createdAtString {
                Group {
                    Text("Created at: ") + Text(createdAt).bold()
                }
                .frame(maxWidth: .infinity)
            }
            
            if let editedAt = cat.editedAtString {
                Group {
                    Text("Updated at: ") + Text(editedAt).bold()
                }
                .frame(maxWidth: .infinity)
            }
    }
    
    private func loadCats(tag: String) {
        Task {
            do {
                let skip = 0
                let limit = 5 /// We only want 4 but need an extra one if the profile is duplicated
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
        Image("waiting")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundStyle(Color(UIColor.label))
            .opacity(0.8)
    }
}


#Preview {
    NavigationStack {
        CatDetailView(cat: Cat(id: "5llbIzGS52clSUik", size: 1.0, tags: ["white", "tag2"], mimetype: "image/gif", createdAt: nil, editedAt: nil),
                catImage: Image("waiting"))
    }
}
