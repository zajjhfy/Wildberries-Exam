//
//  DSSnackBar.swift
//  DesignSystem
//
//  Снекбар — всплывающее уведомление об ошибке
//

import SwiftUI

/// Всплывающее уведомление (снекбар). Показывает иконку предупреждения и текст.
public struct DSSnackBar: View {

    private let title: String

    public init(title: String) {
        self.title = title
    }

    public var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(Color.primary)
                    .frame(width: 24, height: 24)
                Image(systemName: "exclamationmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(DSColors.screenBackground)
            }
            .padding(.leading, 12)

            Text(title)
                .font(DSTypography.addressTitle)
                .foregroundStyle(DSColors.textPrimary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
        }
        .background(DSColors.screenBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 5, x: 0, y: 4)
        .shadow(color: Color.black.opacity(0.05), radius: 1, x: 0, y: 0)
    }
}

#Preview {
    DSSnackBar(title: "Не получилось, попробуйте еще раз")
}

#Preview("Тёмная") {
    DSSnackBar(title: "Не получилось, попробуйте еще раз")
        .padding()
        .background(DSColors.screenBackground)
        .preferredColorScheme(.dark)
}