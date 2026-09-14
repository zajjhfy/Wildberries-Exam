//
//  DSCloseButton.swift
//  DesignSystem
//
//  Кнопка закрытия
//

import SwiftUI

/// Кнопка закрытия
public struct DSCloseButton: View {

    private let action: () -> Void
    private let color: Color

    public init(
        action: @escaping () -> Void,
        color: Color = Color.secondary
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
                    .rotationEffect(.degrees(45))
                Rectangle()
                    .fill(color)
                    .frame(width: 16, height: 2)
                    .rotationEffect(.degrees(-45))
            }
            .frame(width: 24, height: 24)
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    DSCloseButton() {}
        .padding()
}

#Preview("Тёмная") {
    DSCloseButton() {}
        .padding()
        .background(DSColors.screenBackground)
        .preferredColorScheme(.dark)
}