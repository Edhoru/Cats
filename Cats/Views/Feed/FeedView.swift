//
//  ContentView.swift
//  Cats
//
//  Created by Alberto on 23/02/24.
//

import SwiftData
import SwiftUI

struct FeedView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.modelContext) var modelContext
    
    @State var cats: [Cat] = []
    
    @StateObject private var viewModel = FeedViewModel()
    
    @State private var selectedCat: Cat?
    @State var safeAreaInsets: EdgeInsets = .init()
    
    var numberOfColumns: Int {
        switch horizontalSizeClass {
        case .compact:
            switch verticalSizeClass {
            case .compact:
                return 2
            case .regular:
                return 1
            default:
                return 1
            }
        case .regular:
            return 3
        default:
            return 1
        }
    }
    
    var columnSpacing: CGFloat {
        return 10
    }
    
    var columns: [GridItem] {
        return [GridItem](repeating: GridItem(.flexible(), spacing: columnSpacing), count: numberOfColumns)
    }
    
    private func gridItemWidth(horizontalSafeArea: CGFloat) -> CGFloat {
        return (UIScreen.main.bounds.width - horizontalSafeArea - columnSpacing * CGFloat(numberOfColumns - 1)) / CGFloat(numberOfColumns)
    }
    
    var horizontalSafeArea: CGFloat {
        safeAreaInsets.leading +
        safeAreaInsets.trailing +
        (horizontalPadding * 2)
    }
    
    var horizontalPadding: CGFloat = 8
    
    var body: some View {
        NavigationStack {
            ZStack {
                Rectangle()
                    .fill(colorsManager.selectedColor(for: .background).gradient)
                    .ignoresSafeArea()
                    .padding(.horizontal, -horizontalPadding)
                
                ScrollView {
                    VStack(spacing: 2) {
                        LazyVGrid(columns: columns, spacing: columnSpacing) {
                            ForEach(viewModel.cats) { cat in
                                Button {
                                    selectedCat = cat
                                } label: {
                                    CatCard(itemWidth: gridItemWidth(horizontalSafeArea: horizontalSafeArea),
                                            cat: cat) { tag in
                                        viewModel.addSelectedTag(tag) { reload in
                                            if reload {
                                                viewModel.loadCats(replace: true)
                                            }
                                        }
                                    }
                                            .environmentObject(colorsManager)
                                            .environmentObject(fontManager)
                                            .environment(\.modelContext, modelContext)
                                }
                            }
                        }
                    }
                    
                    if !viewModel.cats.isEmpty && !viewModel.isLoadingCats && !viewModel.noMoreResults && viewModel.shouldLoadMoreCats {
                        LazyVStack {
                            Image(systemName: "arrow.circlepath")
                                .fontWeight(.black)
                                .padding(8)
                                .foregroundStyle(Color(UIColor.label))
                                .background(Circle().fill(.ultraThinMaterial))
                                .onAppear {
                                    if viewModel.shouldLoadMoreCats {
                                        Task {
                                            viewModel.loadCats(replace: false)
                                        }
                                    }
                                    viewModel.shouldLoadMoreCats = false
                                }
                        }
                    } else if viewModel.cats.isEmpty {
                        Color.clear
                            .onAppear {
                                Task {
                                    viewModel.loadCats(replace: false)
                                }
                            }
                    }
                }
                .padding(.bottom)
                
                if viewModel.isLoadingCats || viewModel.isLoadingTags {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .frame(width: 100, height: 100)
                            .background(.ultraThickMaterial)
                        ProgressView()
                            .tint(.white)
                    }
                } else if viewModel.cats.isEmpty && viewModel.firstLoadIsFinished {
                    ContentUnavailableView("There are no cats here", systemImage: "cat", description: Text("Try to use different tags.")
                        .font(.custom(FontManager().selectedFontName ?? "", size: UIFont.systemFontSize)))
                }
            }
            .padding(.horizontal, horizontalPadding)
            .getSafeAreaInsets($safeAreaInsets)
            .navigationTitle("Cats")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    TagsMenu(tags: viewModel.selectedTags) { action in
                        switch action {
                        case .removeAll:
                            viewModel.setSelectedTags([])
                            viewModel.loadCats(replace: true)
                        case .remove(let tag):
                            viewModel.setSelectedTags(viewModel.selectedTags.filter({ $0 != tag}))
                            viewModel.loadCats(replace: true)
                        case .showTagsSheet:
                            viewModel.showingTagsSheet = true
                        }
                    }
                }
            }
        }
        .customFont()
        .sheet(isPresented: $viewModel.showingTagsSheet, onDismiss: {
            viewModel.shouldLoadMoreCats = true
        }, content: {
            TagsView(tags: viewModel.allTags, selectedTags: $viewModel.selectedTags) {
                viewModel.loadCats(replace: true)
            }
            .environmentObject(colorsManager)
            .environmentObject(fontManager)
            .presentationDetents([.medium, .large])
        })
        .sheet(item: $selectedCat, content: { cat in
            DetailView(cat: cat, catImage: nil)
                .environmentObject(colorsManager)
                .environmentObject(fontManager)
                .environment(\.modelContext, modelContext)
        })
        .onAppear {
            Task {
                viewModel.loadTags()
            }
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
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
        .environmentObject(ColorsManager())
        .environmentObject(FontManager())
}
