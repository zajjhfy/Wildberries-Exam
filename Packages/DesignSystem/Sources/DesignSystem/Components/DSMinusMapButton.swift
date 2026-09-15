//
//  DSMinusMapButton.swift
//  DesignSystem
//
//  Кнопка уменьшения карты
//

import SwiftUI

/// Кнопка уменьшения карты
public struct DSMinusMapButton: View {

    private let action: () -> Void
    private let color: Color

    public init(
        action: @escaping () -> Void,
        color: Color = Color.primary
    ) {
        self.action = action
        self.color = color
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
            }
            .frame(width: 40, height: 40)
            .background(DSColors.screenBackground)
            .contentShape(Rectangle())
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0)
    }
}

#Preview {
    DSMinusMapButton() {}
        .padding()
}

#Preview("Тёмная") {
    DSMinusMapButton() {}
        .padding()
        .background(DSColors.screenBackground)
        .preferredColorScheme(.dark)
}