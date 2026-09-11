//
//  DSCloseMapButton.swift
//  DesignSystem
//
//  Кнопка закрытия карты
//

import SwiftUI

/// Кнопка закрытия карты
public struct DSCloseMapButton: View {

    private let action: () -> Void
    private let color: Color

    public init(
        action: @escaping () -> Void,
        color: Color = .gray
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
            .frame(width: 40, height: 40)
            .background(.white)
            .contentShape(Rectangle())
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0)
    }
}

#Preview {
    DSCloseMapButton() {}
        .padding()
}