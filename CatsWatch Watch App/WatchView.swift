//
//  ContentView.swift
//  CatsWatch Watch App
//
//  Created by Alberto on 28/05/24.
//

import SwiftUI

import SwiftUI

struct WatchView: View {
    @StateObject private var viewModel = WatchViewModel()
    @State private var isLiked = false
    
    var body: some View {
        TabView {
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    Rectangle()
                        .overlay {
                            if let imageData = viewModel.data {
                                Image(uiImage: UIImage(data: imageData) ?? UIImage(named: "waiting")!)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                placeholderImage
                            }
                        }
                    
                    VStack {
                        HStack {
                            Spacer()
                            Text(viewModel.catDateString())
                                .font(.caption.bold())
                                .padding(.horizontal, 18)
                                .padding(.vertical)
                        }
                        .background(.ultraThinMaterial)
                    }
                }
                .ignoresSafeArea()
            }
            .onAppear {
                viewModel.fetchRandomCat()
            }
            
            
            HStack {
                Button(action: {
                    isLiked.toggle()
                }) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .white)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewModel.data = nil
                    viewModel.fetchRandomCat(bypassCache: true)
                }) {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.white)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
                
                Button(action: {
                    viewModel.openCatProfile()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.white)
                }
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity)
            }
            .padding()
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
}

#Preview {
    WatchView()
}
