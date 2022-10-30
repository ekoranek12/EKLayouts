//
//  ChipLayout.swift
//  WWDC Highlights
//
//  Created by Eddie Koranek on 10/29/22.
//

import SwiftUI


struct ChipLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let width = proposal.width,
              width > .zero,
              subviews.isEmpty == false
        else {
            return .zero
        }

        let dimensions = position(subviews, width: width, origin: .zero)
        return dimensions.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let dimensions = position(subviews, width: bounds.width, origin: bounds.origin)

        zip(dimensions.rects, subviews).forEach { rect, subview in
            let proposal = ProposedViewSize(rect.size)
            subview.place(at: rect.origin, proposal: proposal)
        }
    }


    private func position(_ subviews: Subviews, width: CGFloat, origin: CGPoint) -> Dimensions {
        var x = origin.x
        var y = origin.y

        var rowHeight: CGFloat = .zero
        var rects: [CGRect] = []

        for subview in subviews {
            let size = subview.dimensions(in: .unspecified)

            if x + size.width > width + origin.x {
                y += rowHeight + spacing
                x = origin.x
                rowHeight = .zero
            }

            rowHeight = max(rowHeight, size.height)
            rects.append(CGRect(x: x, y: y, width: size.width, height: size.height))

            x += size.width + spacing
        }

        return Dimensions(size: CGSize(width: width, height: y + rowHeight),
                                rects: rects)
    }
    

    private struct Dimensions {
        let size: CGSize
        let rects: [CGRect]
    }
}
