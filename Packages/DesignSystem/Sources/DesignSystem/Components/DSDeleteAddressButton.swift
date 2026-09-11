//
//  DSDeleteAddressButton.swift
//  DesignSystem
//
//  Кнопка удаления адреса
//

import SwiftUI

/// Кнопка удаления адреса
public struct DSDeleteAddressButton: View {

    private let action: () -> Void

    public init(
        action: @escaping () -> Void
    ) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Image(systemName: "trash")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.red)
                .frame(width: 40, height: 40)
                .background(.white)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0)
    }
}

#Preview {
    DSDeleteAddressButton() {}
        .padding()
}