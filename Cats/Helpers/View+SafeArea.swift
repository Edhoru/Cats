//
//  View+SafeArea.swift
//  Cats
//
//  Created by Alberto on 06/06/24.
//

import SwiftUI

struct SafeAreaInsetsKey: PreferenceKey {
    static var defaultValue = EdgeInsets()
    static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
        value = nextValue()
    }
}

extension View {
    func getSafeAreaInsets(_ safeInsets: Binding<EdgeInsets>) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: SafeAreaInsetsKey.self, value: proxy.safeAreaInsets)
            }
                .onPreferenceChange(SafeAreaInsetsKey.self) { value in
                    safeInsets.wrappedValue = value
                }
        )
    }
}
