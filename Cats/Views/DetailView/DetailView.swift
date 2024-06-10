//
//  CatView.swift
//  Cats
//
//  Created by Alberto on 29/02/24.
//

import SwiftUI

struct DetailView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    @Environment(\.dismissAction) private var dismissAction
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.modelContext) var modelContext
    
    @StateObject private var viewModel: DetailViewModel
    
    @State var selectedCat: Cat?
    
    let catImage: Image?

    init(cat: Cat, catImage: Image?) {
        self._viewModel = StateObject(wrappedValue: DetailViewModel(cat: cat))
        self.catImage = catImage
    }
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorsManager.selectedColor(for: .background).gradient)
                .ignoresSafeArea()
            
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
                            CachedAsyncImage(url: viewModel.cat.imageURL()) { phase in
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
                            viewModel.trigger += 1
                            if viewModel.cat.isFavorited(modelContext: modelContext) {
                                viewModel.cat.unfavorite(modelContext: modelContext)
                            } else {
                                viewModel.cat.favorite(modelContext: modelContext)
                            }
                        }, label: {
                            Image(systemName: "heart")
                                .font(.title)
                                .symbolVariant(viewModel.cat.isFavorited(modelContext: modelContext) ? .fill : .circle)
                                .symbolEffect(.bounce, value: viewModel.trigger)
                                .foregroundStyle(viewModel.cat.isFavorited(modelContext: modelContext) ? .red : .white)
                                .shadow(radius: 2)
                        })
                        .padding(.horizontal, viewModel.cat.isFavorited(modelContext: modelContext) ? 3 : 4)
                        .padding(.vertical, viewModel.cat.isFavorited(modelContext: modelContext) ? 6 : 4)
                    }
                    .listRowInsets(EdgeInsets())
                    
                    datesContainerView
                    
                    ForEach(viewModel.cat.safeTags, id: \.self) { tag in
                        Section {
                            section(for: tag)
                        } header: {
                            HStack {
                                Text(tag)
                                    .customFont(.title)
                                    .textCase(.uppercase)
                                
                                Spacer()
                                
                                if !(viewModel.catsByTag[tag]?.isEmpty ?? true) {
                                    Button {
                                        dismissAction?(tag)
                                    } label: {
                                        Text("Show more")
                                            .customFont(.callout)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                        .onAppear {
                            viewModel.loadCats(tag: tag)
                        }
                    }
                }}
            .frame(maxWidth: .infinity)
            .listStyle(.plain)
            .onAppear {
                viewModel.fetchCatDetails()
            }
            .sheet(item: $selectedCat) { cat in
                DetailView(cat: cat, catImage: nil)
                    .environmentObject(colorsManager)
                    .environmentObject(fontManager)
            }
        }
        .customFont()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    @ViewBuilder
    private func section(for tag: String) -> some View {
        if let cats = viewModel.catsByTag[tag] {
            if cats.isEmpty {
                Text("There are no more results for \"\(tag)\"")
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
                    .frame(height: 50)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 24) {
                        ForEach(cats, id: \.self) { cat in
                            Button {
                                selectedCat = cat
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
        if let createdAt = viewModel.cat.createdAtString {
            Group {
                Text("Created at: ") + Text(createdAt).bold()
            }
            .frame(maxWidth: .infinity)
        }
        
        if let editedAt = viewModel.cat.editedAtString {
            Group {
                Text("Updated at: ") + Text(editedAt).bold()
            }
            .frame(maxWidth: .infinity)
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

#if os(iOS)
#Preview {
    NavigationStack {
        DetailView(
            cat: Cat(
                id: "5llbIzGS52clSUik",
                size: 1.0,
                tags: ["white", "tag2"],
                mimetype: "image/gif",
                createdAt: nil,
                editedAt: nil
            ),
            catImage: Image("waiting")
        )
    }
    .environmentObject(ColorsManager())
    .environmentObject(FontManager())
}
#endif
