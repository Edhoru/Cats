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
    var body: some Scene {
        WindowGroup {
            MainView()
                .modelContainer(for: Cat.self)
        }
    }
}
