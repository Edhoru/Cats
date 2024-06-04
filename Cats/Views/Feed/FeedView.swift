//
//  ContentView.swift
//  Cats
//
//  Created by Alberto on 23/02/24.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach(viewModel.cats) { cat in
                            NavigationLink {
                                CatDetailView(cat: cat, catImage: nil)
                            } label: {
                                #if os(iOS)
                                CatCard(cat: cat) { tag in
                                    viewModel.selectedTags = [tag]
                                    Task {
                                        viewModel.isLoadingCats = true
                                        await viewModel.loadCats(replace: true)
                                    }
                                }
                                .anchorPreference(key: MAnchorKey.self, value: .bounds, transform: { anchor in
                                    return [cat.id: anchor]
                                })
                                #else
                                Text("vision")
                                #endif
                            }
                        }
                    }
                    
                    if !viewModel.isLoadingCats && !viewModel.noMoreResults {
                        LazyVStack {
                            Image(systemName: "arrow.circlepath")
                                .fontWeight(.black)
                                .padding(8)
                                .foregroundStyle(Color(UIColor.label))
                                .background(Circle().fill(.ultraThinMaterial))
                                .onAppear {
                                    if viewModel.shouldLoadMoreCats {
                                        Task {
                                            await viewModel.loadCats(replace: false)
                                        }
                                    }
                                    viewModel.shouldLoadMoreCats = false
                                }
                        }
                    } else {
                        Color.clear
                            .onAppear {
                                Task {
                                    await viewModel.loadCats(replace: false)
                                }
                            }
                    }
                }
                
                if viewModel.isLoadingCats || viewModel.isLoadingTags {
                    ProgressView()
                }
            }
            .navigationTitle("Cats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    TagsMenu(tags: viewModel.selectedTags) { action in
                        switch action {
                        case .removeAll:
                            viewModel.selectedTags = []
                        case .remove(let tag):
                            viewModel.selectedTags = viewModel.selectedTags.filter({ $0 != tag})
                        case .showTagsSheet:
                            viewModel.showingTagsSheet = true
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.showingTagsSheet, onDismiss: {
            viewModel.shouldLoadMoreCats = true
        }, content: {
            TagsView(tags: viewModel.allTags, selectedTags: $viewModel.selectedTags) {
                print("Date: ", Date())
                Task {
                    await viewModel.loadCats(replace: true)
                }
            }
            .presentationDetents([.medium, .large])
        })
        .onAppear {
            Task {
                await viewModel.loadTags()
            }
        }
        .overlayPreferenceValue(MAnchorKey.self, { value in
            GeometryReader(content: { geometry in
                ForEach(viewModel.cats) { cat in
                    if let anchor = value[cat.id] {
                        let rect = geometry[anchor]
                        CachedAsyncImage(url: cat.imageURL(width: UIScreen.main.bounds.width)) { phase in
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
                        .offset(x: rect.minX, y: rect.minY)
                        .opacity(0.0)
                    }
                }
            })
        })
    }
    
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
    FeedView()
}
