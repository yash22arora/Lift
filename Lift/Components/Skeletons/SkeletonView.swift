// SkeletonView.swift
// Lift — Reusable shimmer skeleton for loading states

import SwiftUI

struct SkeletonView: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat
    @State private var shimmer = false

    init(width: CGFloat? = nil, height: CGFloat = 16, cornerRadius: CGFloat = Radius.sm) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(
                LinearGradient(
                    colors: shimmer
                        ? [Color.liftSurface, Color.liftSurfaceElevated, Color.liftSurface]
                        : [Color.liftSurface, Color.liftSurface],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: width, height: height)
            .frame(maxWidth: width == nil ? .infinity : nil)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) {
                    shimmer = true
                }
            }
    }
}

extension View {
    @ViewBuilder
    func skeletonLoading(isLoading: Bool, width: CGFloat? = nil, height: CGFloat = 16) -> some View {
        if isLoading {
            SkeletonView(width: width, height: height)
        } else {
            self
        }
    }
}
