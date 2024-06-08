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
                FavoritesView()
            case .settings:
                SettingsView()
            }
        
        }
    }
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    
    @StateObject private var fontManager = FontManager()
    @StateObject private var colorsManager = ColorsManager()
    
    @State private var selectedTab: Tab = .feed
    
    
    @StateObject private var dismissToRootManager = DismissToRootManager()
    
    var body: some View {
        Group {
            if horizontalSizeClass == .compact {
                TabView(selection: $selectedTab) {
                    ForEach(Tab.allCases, id: \.self) { tab in
                        tab.view
                            .tabItem { Label(tab.rawValue.capitalized,
                                             systemImage: tab.icon) }
                            .environmentObject(fontManager)
                            .environmentObject(colorsManager)
                    }
                }
                .tint(colorsManager.selectedColor(for: .accent))
            } else {
                NavigationSplitView {
                    SidebarView(selectedTab: $selectedTab)
                        .tint(colorsManager.selectedColor(for: .accent))
                } detail: {
                    selectedTab.view
                        .environmentObject(colorsManager)
                        .environmentObject(fontManager)
                }
                .tint(colorsManager.selectedColor(for: .accent))
            }
        }
        .environment(\.dismissAction, dismissToRootManager.dismiss)
        .onAppear {
            dismissToRootManager.dismissAction = { tag in
                NotificationCenter.default.post(name: .dismissToRootWithTag, object: nil, userInfo: ["tag": tag])
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    scene.windows.first?.rootViewController?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
}








#Preview {
    MainView()
}


struct SidebarView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
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
