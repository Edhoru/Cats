//
//  ImageCache.swift
//  Cats
//
//  Created by Alberto on 24/02/24.
//

import SwiftUI

// Define CachedAsyncImage without specifying default content type in extension
struct CachedAsyncImage<Content>: View where Content: View {
    private var url: URL?
    private var scale: CGFloat
    private var transaction: Transaction
    private var content: (AsyncImagePhase) -> Content
    
    init(
        url: URL?,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        @ViewBuilder content: @escaping (AsyncImagePhase) -> Content
    ) {
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
    }
    
    var body: some View {
        AsyncImage(
            url: url,
            scale: scale,
            transaction: transaction,
            content: content
        )
    }
}

