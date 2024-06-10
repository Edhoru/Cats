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
//            Prueba()
                .modelContainer(for: Cat.self)
        }
    }
}


struct Prueba: View {
    var body: some View {
        Text("algo")
    }
}
