//
//  TagLayout.swift
//  Cats
//
//  Created by Alberto on 28/02/24.
//

import SwiftUI

struct TagLayout: Layout {
    /// Layout Properties
    var alignment: Alignment = .center
    /// Both Horizontal & Vertical
    var spacing: CGFloat = 10
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = (proposal.width ?? 0)
        var height: CGFloat = 0
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for (index, row) in rows.enumerated() {
            if index == (rows.count - 1) {
                height += row.maxHeight(proposal)
            } else {
                height += row.maxHeight(proposal) + spacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth, proposal, subviews)
        
        for row in rows {
            /// Changing origin X based on Alignments
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                
                if view == row.last {
                    /// No Spacing
                    return partialResult + width
                }
                /// With Spacing
                return partialResult + width + spacing
            })
            
            let center = (trailing + leading) / 2
            
            /// Resetting Origin X to zero for Each row
            origin.x = (alignment == .leading ? leading :
                        alignment == .trailing ? trailing : center)
            
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                /// Update Origin
                origin.x += (viewSize.width + spacing)
            }
            
            /// Updating Origin Y
            origin.y += (row.maxHeight(proposal) + spacing)
        }
    }
    
    /// Generate Rows based on Available size
    func generateRows(_ maxWidth: CGFloat, _ proposal: ProposedViewSize, _ subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        /// Origin
        var origin = CGRect.zero.origin
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            if (origin.x + viewSize.width + spacing) > maxWidth {
                rows.append(row)
                row.removeAll()
                /// Resetting X Origin since it needs to start from left to right
                origin.x = 0
                row.append(view)
                /// Update Origin X
                origin.x += (viewSize.width + spacing)
            } else {
                /// Adding item to same row
                row.append(view)
                /// Update Origin X
                origin.x += (viewSize.width + spacing)
            }
        }
        
        /// Checking for any exhaust row
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
    }
    
}


extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height
        }.max() ?? 0
    }
}
