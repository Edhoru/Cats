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
