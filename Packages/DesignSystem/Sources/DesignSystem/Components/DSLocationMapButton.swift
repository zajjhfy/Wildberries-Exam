//
//  DSLocationMapButton.swift
//  DesignSystem
//
//  Кнопка геолокации карты
//

import SwiftUI

/// Кнопка геолокации карты
public struct DSLocationMapButton: View {

    private let action: () -> Void
    private let color: Color

    public init(
        action: @escaping () -> Void,
        color: Color = .black
    ) {
        self.action = action
        self.color = color
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "location")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color)
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
    DSLocationMapButton() {}
        .padding()
}