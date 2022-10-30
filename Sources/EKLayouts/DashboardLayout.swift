//
//  DashboardLayout.swift
//  WWDC Highlights
//
//  Created by Eddie Koranek on 10/7/22.
//

import SwiftUI


struct DashboardLayout: Layout {

    var columns: Int


    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        guard let width = proposal.width, width > .zero else { return CGSize.zero }
        let dimension = calculateRects(width: width, subviews: subviews)
        return dimension.size
    }


    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let layoutDetails = calculateRects(width: bounds.width,
                                           startingPoint: CGPoint(x: bounds.minX, y: bounds.minY),
                                           subviews: subviews)

        layoutDetails.rects.indices.forEach { index in
            let rect = layoutDetails.rects[index]
            let subview = subviews[index]
            let proposal = ProposedViewSize(rect.size)
            subview.place(at: rect.origin, proposal: proposal)
        }
    }


    private func calculateRects(width: CGFloat, startingPoint: CGPoint = .zero, subviews: Subviews) -> LayoutDimensions {
        let dimension = width / CGFloat(columns)

        var previousRects: [CGRect] = []
        var totalSize: CGSize = .zero

        var x = startingPoint.x
        var y = startingPoint.y
        var minimumY = startingPoint.y

        let sizes = subviews.map { subview in
            let ratio = subview[TileRatio.self] ?? CGSize(width: 1, height: 1)
            return CGSize(width: dimension * ratio.width, height: dimension * ratio.height)
        }

        for index in sizes.indices {
            let size = sizes[index]

            var proposedRect: CGRect {
                CGRect(origin: CGPoint(x: x, y: y), size: size)
            }

            var xAttempts = 0
            while previousRects.contains(where: { $0.intersects(proposedRect) }) {
                if xAttempts == columns {
                    minimumY = y
                    xAttempts = 0
                }

                if x + size.width >= width {
                    x = startingPoint.x
                    y += dimension
                    xAttempts = 0

                } else {
                    x += dimension
                    xAttempts += 1
                }
            }

            previousRects.append(CGRect(origin: proposedRect.origin, size: size))

            totalSize.width = width
            totalSize.height = max(totalSize.height, proposedRect.maxY)

            x = startingPoint.x
            y = minimumY
        }

        return LayoutDimensions(size: totalSize, rects: previousRects)
    }


    private struct LayoutDimensions {
        let size: CGSize
        let rects: [CGRect]
    }


    struct TileRatio: LayoutValueKey {
        static let defaultValue: CGSize? = nil
    }
}


extension View {
    func tileRatio(width: CGFloat = 1, height: CGFloat = 1) -> some View {
        layoutValue(key: DashboardLayout.TileRatio.self, value: CGSize(width: width, height: height))
    }
}
