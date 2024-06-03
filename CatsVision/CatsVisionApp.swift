//
//  CatsVisionApp.swift
//  CatsVision
//
//  Created by Alberto on 28/05/24.
//

import SwiftUI

@main
struct CatsVisionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            ImmersiveView()
        }.immersionStyle(selection: .constant(.full), in: .full)
    }
}
