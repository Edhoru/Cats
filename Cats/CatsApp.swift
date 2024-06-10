//
//  CatsApp.swift
//  Cats
//
//  Created by Alberto on 23/02/24.
//

import SwiftData
import SwiftUI

@main
struct CatsApp: App {
    @StateObject private var remoteChangeObserver = RemoteChangeObserver()
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: Cat.self)
                .environmentObject(remoteChangeObserver)
        }
    }
}

class RemoteChangeObserver: ObservableObject {
    @Published var changedCats: [Cat] = []

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleStoreRemoteChange(_:)),
            name: .NSPersistentStoreRemoteChange,
            object: nil
        )
    }

    @objc func handleStoreRemoteChange(_ notification: Notification) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
        }
    }
}

struct TestMainView: View {
    @EnvironmentObject var remoteChangeObserver: RemoteChangeObserver

    var body: some View {
        TestFeedView()
            .environmentObject(remoteChangeObserver)
    }
}

struct TestFeedView: View {
    @EnvironmentObject var remoteChangeObserver: RemoteChangeObserver
    @Environment(\.modelContext) var modelContext
    @StateObject private var viewModel = FeedViewModel()

    var body: some View {
        List {
            ForEach(viewModel.cats) { cat in
                TestCardView(cat: cat)
                    .environment(\.modelContext, modelContext)
            }
        }
        .onAppear {
            Task {
                viewModel.loadCats(replace: true)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .favoritesUpdated)) { _ in
            Task {
                viewModel.loadCats(replace: true)
            }
        }
    }
}


struct TestCardView: View {
    @EnvironmentObject var remoteChangeObserver: RemoteChangeObserver
    @Environment(\.modelContext) var modelContext
    let cat: Cat

    var body: some View {
        HStack {
            Text(cat.safeId)
            if cat.isFavorited(modelContext: modelContext) {
                Image(systemName: "star.fill").foregroundColor(.yellow)
            }
        }
    }
}
