//
//  DSPlusMapButton.swift
//  DesignSystem
//
//  Кнопка увеличения карты
//

import SwiftUI

/// Кнопка увеличения карты
public struct DSPlusMapButton: View {

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
                    .rotationEffect(.degrees(90))
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
    DSPlusMapButton() {}
        .padding()
}

#Preview("Тёмная") {
    DSPlusMapButton() {}
        .padding()
        .background(DSColors.screenBackground)
        .preferredColorScheme(.dark)
}