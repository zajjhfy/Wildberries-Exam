//
//  DSSearchButton.swift
//  DesignSystem
//
//  Кнопка поиска
//

import SwiftUI

/// Кнопка поиска: иконка + подпись «Поиск».
public struct DSSearchButton: View {

    private let action: () -> Void

    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Image(.search)
                    .frame(width: 50, height: 50)
                Text("Поиск")
                    .font(DSTypography.searchButtonTitle)
                    .padding(.bottom, 9)
                    .padding(.top, 9)
                    .padding(.trailing, 17)
                    .foregroundStyle(DSColors.textPrimary)
            }
            .background(DSColors.searchBackground)
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        DSColors.textSecondary.opacity(0.3),
                        lineWidth: 1
                    )
            )
        }
    }
}

#Preview {
    DSSearchButton() {}
        .padding()
}

#Preview("Тёмная") {
    DSSearchButton() {}
        .padding()
        .background(DSColors.screenBackground)
        .preferredColorScheme(.dark)
}
