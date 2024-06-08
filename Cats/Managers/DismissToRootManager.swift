//
//  DismissToRootManager.swift
//  Cats
//
//  Created by Alberto on 08/06/24.
//

import SwiftUI

class DismissToRootManager: ObservableObject {
    @Published var dismissAction: ((String) -> Void)?

    func dismiss(with tag: String) {
        dismissAction?(tag)
    }
}

struct DismissActionKey: EnvironmentKey {
    static let defaultValue: ((String) -> Void)? = nil
}

extension EnvironmentValues {
    var dismissAction: ((String) -> Void)? {
        get { self[DismissActionKey.self] }
        set { self[DismissActionKey.self] = newValue }
    }
}
