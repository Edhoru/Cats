//
//  SettingsView.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var colorsManager: ColorsManager
    @EnvironmentObject var fontManager: FontManager
    
    @State private var selectedAccentColor: Color
    @State private var selectedBackgroundColor: Color
    
    init() {
        _selectedAccentColor = State(initialValue: ColorsManager().selectedColor(for: .accent))
        _selectedBackgroundColor = State(initialValue: ColorsManager().selectedColor(for: .background))
    }
    
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
                    
                    Button("Reset") {
                        colorsManager.reset()
                    }
                    .foregroundStyle(colorsManager.selectedColor(for: .accent))
                }
            }
            .scrollContentBackground(.hidden)
            .background(selectedBackgroundColor)
        }
        .customFont()
        .onChange(of: selectedAccentColor, { oldValue, newValue in
            colorsManager.updateColor(to: newValue, usage: .accent)
        })
        .onChange(of: selectedBackgroundColor, { oldValue, newValue in
            colorsManager.updateColor(to: newValue, usage: .background)
        })
        .onAppear {
            selectedAccentColor = colorsManager.selectedColor(for: .accent)
            selectedBackgroundColor = colorsManager.selectedColor(for: .background)
        }
    }
}

#Preview {
    let fontManager = FontManager()
    let colorManager = ColorsManager()
    return SettingsView()
        .environmentObject(fontManager)
        .environmentObject(colorManager)
}
