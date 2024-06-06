//
//  SettingsView.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    @State private var selectedAccentColor: Color = .customForeground
    @State private var selectedBackgroundColor: Color = .customBackground
    
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
                        .onChange(of: selectedAccentColor, initial: true) { oldValue, newValue in
                            colorsManager.updateColor(to: newValue, usage: .accent)
                        }
                    
                    ColorPicker("Background Color", selection: $selectedBackgroundColor)
                        .onChange(of: selectedBackgroundColor, initial: true) { oldValue, newValue in
                            colorsManager.updateColor(to: newValue, usage: .background)
                        }
                    
                    Button("Reset") {
                        colorsManager.reset()
                        selectedAccentColor = colorsManager.selectedColor(for: .accent)
                        selectedBackgroundColor = colorsManager.selectedColor(for: .background)
                    }
                    .foregroundStyle(colorsManager.selectedColor(for: .accent))
                }
            }
            .scrollContentBackground(.hidden)
            .background(selectedBackgroundColor)
        }
        .customFont()
        .onAppear {
            selectedAccentColor = colorsManager.selectedColor(for: .accent)
            selectedBackgroundColor = colorsManager.selectedColor(for: .background)
        }
    }
}

#Preview {
    let fontManager = FontManager()
    let colorsManager = ColorsManager()
    return SettingsView()
        .environmentObject(fontManager)
        .environmentObject(colorsManager)
}
