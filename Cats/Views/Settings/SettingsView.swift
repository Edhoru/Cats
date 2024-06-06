//
//  SettingsView.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var fontManager: FontManager
    
    @State var selectedAccentColor = Color.accentColor
    @State var selectedBackgroundColor = Color.background
    
    var body: some View {
        NavigationStack {
                Form {
                    Section("Fonts") {
                        NavigationLink {
                            FontListView()
                        } label: {
                            HStack {
                                Text("Select Font")
                                Text((fontManager.selectedFontName != nil) ? " - \(fontManager.selectedFontName ?? "")" : "")
                                    .customFont(.caption).foregroundStyle(selectedAccentColor)
                            }
                        }
                    }
                    
                    Section("Theme") {
                        ColorPicker("Accent Color", selection: $selectedAccentColor)
                        ColorPicker("Background Color", selection: $selectedBackgroundColor)
                        
                    }
                }
                .scrollContentBackground(.hidden)
                .background(selectedBackgroundColor)
            }
        .customFont()
    }
}

#Preview {
    let fontManager = FontManager()
    return SettingsView()
        .environmentObject(fontManager)
}

