//
//  MainView.swift
//  Cats
//
//  Created by Alberto on 28/05/24.
//

import SwiftUI

struct MainView: View {
    enum Tab: String, CaseIterable, Identifiable {
        var id: Self {
            return self
        }
        
        case feed
        case favorites
        case settings
        
        var icon: String {
            switch self {
            case .feed:
                "house"
            case .favorites:
                "star"
            case .settings:
                "gear"
            }
        }
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedTab: Tab = .feed
    @State private var selectedFeedItem: FeedItem?
    @State private var selectedFavoriteItem: FavoriteItem?
    
    var body: some View {
        if horizontalSizeClass == .compact {
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text("algo")
                        .tabItem { Label(tab.rawValue.capitalized,
                                         systemImage: tab.icon) }
                }
            }
        } else {
            NavigationSplitView {
                SidebarView(selectedTab: $selectedTab)
            } detail: {
                switch selectedTab {
                case .feed:
                    NavigationSplitView {
                        FeedListView(selectedItem: $selectedFeedItem)
                            .toolbar(removing: .sidebarToggle)
                            .toolbar(.hidden, for: .navigationBar)
                    } detail: {
                        if let selectedFeedItem = selectedFeedItem {
                            FeedDetailView(feedItem: selectedFeedItem)
                        } else {
                            Text("Select a feed item")
                        }
                    }
                    .listStyle(.plain)
                    .toolbar(removing: .sidebarToggle)


                case .favorites:
                    FavoriteListView(selectedItem: $selectedFavoriteItem)
                default:
                    SettingsView()
                }
            }

//            switch selectedTab {
//            case .feed, .favorites:
//                NavigationSplitView(columnVisibility: .constant(.doubleColumn)) {
//                    SidebarView(selectedTab: $selectedTab)
//                } content: {
//                    switch selectedTab {
//                    case .feed:
//                        FeedListView(selectedItem: $selectedFeedItem)
//                    case .favorites:
//                        FavoriteListView(selectedItem: $selectedFavoriteItem)
//                    default:
//                        EmptyView()
//                    }
//                } detail: {
//                    switch selectedTab {
//                    case .feed:
//                        if let selectedFeedItem = selectedFeedItem {
//                            FeedDetailView(feedItem: selectedFeedItem)
//                        } else {
//                            Text("Select a feed item")
//                        }
//                    case .favorites:
//                        if let selectedFavoriteItem = selectedFavoriteItem {
//                            FavoriteDetailView(favoriteItem: selectedFavoriteItem)
//                        } else {
//                            Text("Select a favorite item")
//                        }
//                    default:
//                        EmptyView()
//                    }
//                }
//            case .settings:
//                NavigationSplitView {
//                    SidebarView(selectedTab: $selectedTab)
//                } detail: {
//                    SettingsView()
//                }
//            }
        }
    }
}

#Preview {
    MainView()
}


struct SidebarView: View {
    @Binding var selectedTab: MainView.Tab
    
    var body: some View {
        List(MainView.Tab.allCases) { tab in
            Button {
                selectedTab = tab
            } label: {
            Label(tab.rawValue.capitalized,
                  systemImage: tab.icon)
        }
        }
    }
}


struct FeedItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

struct FavoriteItem: Identifiable, Hashable {
    let id = UUID()
    let title: String
}

struct FeedListView: View {
    @Binding var selectedItem: FeedItem?

    var body: some View {
        List {
            ForEach([FeedItem(title: "Feed Item 1"), FeedItem(title: "Feed Item 2")]) { item in
                NavigationLink(destination: FeedDetailView(feedItem: item), tag: item, selection: $selectedItem) {
                    Text(item.title)
                }
            }
        }
        .navigationTitle("Feed")
    }
}

struct FavoriteListView: View {
    @Binding var selectedItem: FavoriteItem?

    var body: some View {
        List {
            ForEach([FavoriteItem(title: "Favorite Item 1"), FavoriteItem(title: "Favorite Item 2")]) { item in
                NavigationLink(destination: FavoriteDetailView(favoriteItem: item), tag: item, selection: $selectedItem) {
                    Text(item.title)
                }
            }
        }
        .navigationTitle("Favorites")
    }
}

struct FeedDetailView: View {
    let feedItem: FeedItem

    var body: some View {
        Text("Detail for \(feedItem.title)")
    }
}

struct FavoriteDetailView: View {
    let favoriteItem: FavoriteItem

    var body: some View {
        Text("Detail for \(favoriteItem.title)")
    }
}

struct SettingsView: View {
    var body: some View {
        Text("Settings")
            .navigationTitle("Settings")
    }
}
