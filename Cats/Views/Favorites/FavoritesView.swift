//
//  FavoritesView.swift
//  Cats
//
//  Created by Alberto on 05/06/24.
//

import SwiftUI

struct FavoritesView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    enum TagFilterOption: String, CaseIterable {
        case anyTag = "Any Tag"
        case allTags = "All Tags"
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @Namespace private var animation
    
    @State var favoritedCats: [Cat]?
    @State private var unfavoritedCats = [Cat]()
    @State private var selectedCat: Cat?
    @State private var selectedTags = [String]()
    @State var safeAreaInsets: EdgeInsets = .init()
    @State private var filterOption: TagFilterOption = .anyTag
    @State private var showDetailView: Bool = false
    
    let cardWidth: CGFloat = 150
    
    var numberOfColumns: Int {
        switch horizontalSizeClass {
        case .compact:
            switch verticalSizeClass {
            case .compact:
                return 3
            case .regular:
                return 2
            default:
                return 2
            }
        case .regular:
            return 4
        default:
            return 2
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
        ZStack {
            Rectangle()
                .fill(Color.customBackground.gradient)
                .ignoresSafeArea()
            
            VStack {
                if let favoritedCats = favoritedCats, !favoritedCats.isEmpty {
                        VStack {
                            ScrollView(.horizontal, showsIndicators: false) {
                                let tags = Array(Set(favoritedCats.flatMap({ $0.tags }))).sorted()
                                HStack {
                                    ForEach(tags, id: \.self) { tag in
                                        Button {
                                            withAnimation {
                                                if selectedTags.contains(tag) {
                                                    selectedTags.removeAll(where: { $0 == tag })
                                                } else {
                                                    selectedTags.append(tag)
                                                }
                                            }
                                        } label: {
                                            let tagForeground: Color = selectedTags.contains(tag) ? .white : .customForeground
                                            let tagBackground: Color = selectedTags.contains(tag) ? .customForeground : .white
                                            TagView(tag: tag, foregroundColor: tagForeground, backgroundColor: tagBackground)
                                        }
                                    }
                                }
                                .padding(.horizontal, 12)
                            }
                            
                            Picker("Filter Options", selection: $filterOption) {
                                ForEach(TagFilterOption.allCases, id: \.self) { option in
                                    Text(option.rawValue).tag(option)
                                }
                            }
                            .customFont()
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal, 12)
                        }
                        .padding(.vertical, 12)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: columnSpacing) {
                            ForEach(filter(cats: favoritedCats)) { cat in
                                Button {
                                    withAnimation(.spring()) {
                                        selectedCat = cat
                                    }
                                } label: {
                                    FavoriteCatCard(itemWidth: cardWidth, cat: cat) {
                                        withAnimation {
                                            self.favoritedCats?.removeAll(where: { $0.id == cat.id })
                                            unfavoritedCats.append(cat)
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    .padding(.horizontal)
                } else {
                    ContentUnavailableView("No favorites yet", systemImage: "cat", description: Text("Yo don't have any favorites yet, go to the feed and pick your favorites")
                        .font(.custom(FontManager().selectedFontName ?? "", size: UIFont.systemFontSize))
                    )
                }
            }
            
            if !unfavoritedCats.isEmpty {
                VStack {
                    Spacer()
                    Button {
                        if let lastCat = unfavoritedCats.last {
                            withAnimation {
                                favoritedCats?.append(lastCat)
                                unfavoritedCats.removeLast()
                            }
                        }
                    } label: {
                        Label("Undo", systemImage: "arrow.uturn.backward")
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            
            if let selectedCat = selectedCat {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring()) {
                                self.selectedCat = nil
                            }
                        }
                    VStack {
                        Spacer()
                        FavoriteCatCard(itemWidth: geometry.size.width - 20, cat: selectedCat)
                            .padding(10)
                        Button("Open Detail View") {
                            showDetailView.toggle()
                        }
                        Spacer()
                    }
                }
            }
        }
        .customFont()
        .onReceive(NotificationCenter.default.publisher(for: Cat.favoritesUpdatedNotification)) { _ in
            favoritedCats = Cat.getFavoritedCats()
        }
        .onAppear {
            if favoritedCats == nil {
                favoritedCats = Cat.getFavoritedCats()
            }
        }
        .sheet(isPresented: $showDetailView) {
            if let selectedCat = selectedCat {
                CatDetailView(cat: selectedCat, catImage: nil)
            }
        }
    }
    
    func filter(cats: [Cat]) -> [Cat] {
        switch filterOption {
        case .anyTag:
            return selectedTags.isEmpty ? cats : cats.filter { cat in
                !Set(cat.tags).isDisjoint(with: selectedTags)
            }
        case .allTags:
            return selectedTags.isEmpty ? cats : cats.filter { cat in
                Set(selectedTags).isSubset(of: Set(cat.tags))
            }
            
        }
    }
}

#Preview {
    let cats: [Cat] = [Cat(id: "a", size: 1.0, tags: ["tag1", "tag2"], mimetype: "image/gif", createdAt: nil, editedAt: nil),
                Cat(id: "b", size: 1.0, tags: ["tag3", "tag6"], mimetype: "image/gif", createdAt: nil, editedAt: nil),
                Cat(id: "c", size: 1.0, tags: ["tag4", "tag7"], mimetype: "image/gif", createdAt: nil, editedAt: nil),
                Cat(id: "d", size: 1.0, tags: ["tag5", "tag8"], mimetype: "image/gif", createdAt: nil, editedAt: nil)]
    return FavoritesView(favoritedCats: cats)
}
