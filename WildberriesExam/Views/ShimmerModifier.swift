//
//  ShimmerModifier.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem

public struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = -1.0

    public func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let width = geometry.size.width
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0),
                            Color.white.opacity(0.35),
                            Color.white.opacity(0)
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: width * 1.5)
                    .offset(x: phase * width * 1.5)
                }
            )
            .mask(content)
            .onAppear {
                withAnimation(
                    .linear(duration: 1.5)
                    .repeatForever(autoreverses: false)
                ) {
                    phase = 1.0
                }
            }
    }
}

public extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

/// A placeholder card for products during initial loading.
public struct ProductCardSkeletonView: View {
    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 20)
                .fill(DSColors.smoky)
                .frame(width: 174, height: 256)
                .shimmer()

            RoundedRectangle(cornerRadius: 6)
                .fill(DSColors.smoky)
                .frame(width: 120, height: 16)
                .shimmer()

            RoundedRectangle(cornerRadius: 6)
                .fill(DSColors.smoky)
                .frame(width: 80, height: 14)
                .shimmer()

            RoundedRectangle(cornerRadius: 8)
                .fill(DSColors.smoky)
                .frame(width: 100, height: 32)
                .shimmer()
        }
        .padding(.horizontal, 12)
    }
}
