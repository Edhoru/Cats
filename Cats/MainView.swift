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
                "cat"
            case .favorites:
                "star"
            case .settings:
                "gear"
            }
        }
        
        @ViewBuilder
        var view: some View {
            switch self {
            case .feed:
                FeedView()
            case .favorites:
                Text("fav")
            case .settings:
                Text("s")
            }
        
        }
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @State private var selectedTab: Tab = .feed
    
    var body: some View {
        if horizontalSizeClass == .compact {
            TabView(selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    tab.view
                        .tabItem { Label(tab.rawValue.capitalized,
                                         systemImage: tab.icon) }
                }
            }
        } else {
            NavigationSplitView {
                SidebarView(selectedTab: $selectedTab)
            } detail: {
                selectedTab.view
            }
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

