//
//  WatchViewModel.swift
//  CatsWatch Watch App
//
//  Created by Alberto on 07/06/24.
//

import SwiftUI

struct WatchView: View {
    @Environment(\.modelContext) var modelContext
    @StateObject private var viewModel = WatchViewModel()
    @State var isFavorited: Bool = false
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .overlay {
                            if let cat = viewModel.cat {
                                AsyncImage(url: cat.imageURL()) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .clipped()
                                    case .failure(_):
                                        placeholderImage
                                            .overlay(
                                                ZStack {
                                                    Image(systemName: "arrow.circlepath")
                                                        .padding()
                                                        .foregroundStyle(Color.secondary)
                                                    
                                                    Image(systemName: "xmark")
                                                        .foregroundStyle(Color.red)
                                                }
                                            )
                                    case .empty:
                                        placeholderImage
                                            .overlay(
                                                ZStack {
                                                    Image(systemName: "arrow.circlepath")
                                                        .padding()
                                                        .foregroundStyle(Color.secondary)
                                                    
                                                    ProgressView()
                                                        .progressViewStyle(.circular)
                                                }
                                            )
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                            } else {
                                placeholderImage
                            }
                        }
                    
                    watchTagsView
                }
                .ignoresSafeArea()
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            withAnimation {
                                showButtons = true
                            }
                        }
                )
            }
            
            if showButtons {
                ZStack {
                    Rectangle()
                        .ignoresSafeArea()
                        .background(.ultraThinMaterial)
                        .onTapGesture {
                            withAnimation {
                                showButtons = false
                            }
                        }
                    
                    HStack {
                        if let cat = viewModel.cat {
                            Button(action: {
                                if cat.isFavorited(modelContext: modelContext) {
                                    cat.unfavorite(modelContext: modelContext)
                                } else {
                                    cat.favorite(modelContext: modelContext)
                                }
                                isFavorited = cat.isFavorited(modelContext: modelContext)
                            }) {
                                Image(systemName: isFavorited ? "heart.fill" : "heart")
                                    .foregroundColor(isFavorited ? .red : .white)
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        Button(action: {
                            withAnimation {
                                viewModel.cat = nil
                                showButtons = false
                            }
                            viewModel.fetchRandomCat()
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.white)
                        }
                        .buttonStyle(.bordered)
                        
                        if viewModel.cat != nil {
                            Button(action: {
                                viewModel.openCatProfile()
                            }) {
                                Image(systemName: "info.circle")
                                    .foregroundColor(.white)
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .padding()
                }
                .gesture(
                    DragGesture(minimumDistance: 20)
                        .onEnded { value in
                            withAnimation {
                                showButtons = false
                            }
                        }
                )
                .onAppear {
                    if let cat = viewModel.cat {
                        isFavorited = cat.isFavorited(modelContext: modelContext)
                    }
                }
            }
        }
        .onAppear {
            viewModel.fetchRandomCat()
        }
    }
    
    @ViewBuilder
    var placeholderImage: some View {
        Image("waiting")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 100, height: 100)
            .foregroundStyle(Color.primary)
            .opacity(0.8)
    }
    
    @ViewBuilder
    var watchTagsView: some View {
        if let tags = viewModel.cat?.safeTags, !tags.isEmpty {
            VStack {
                Spacer()
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption.bold())
                                .padding(.vertical)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 18)
                }
                .background(.ultraThinMaterial)
            }
        } else {
            EmptyView()
        }
    }
}

#Preview {
    WatchView()
}
