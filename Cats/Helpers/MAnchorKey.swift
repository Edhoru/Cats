//
//  MAnchorKey.swift
//  Cats
//
//  Created by Alberto on 03/06/24.
//

import SwiftUI

struct MAnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()) {
            $1
        }
    }
}
