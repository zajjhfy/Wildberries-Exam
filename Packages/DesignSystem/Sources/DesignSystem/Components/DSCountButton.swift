//
//  DSCountButton.swift
//  DesignSystem
//
//  Кнопка количества товара (степпер «минус / значение / плюс»)
//

import SwiftUI

/// Кнопка количества товара (степпер) — «минус», значение, «плюс».
public struct DSCountButton: View {

    private let count: Int
    private let onIncrement: () -> Void
    private let onDecrement: () -> Void

    public init(
        count: Int,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) {
        self.count = count
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public var body: some View {
        HStack(spacing: 6) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(DSTypography.stepperIcon)
            }
            .frame(width: 16, height: 17)

            Text(count.formatted())
                .font(DSTypography.cartSubtitle)
                .frame(width: 40, height: 17)

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(DSTypography.stepperIcon)
            }
            .frame(width: 16, height: 17)
        }
        .foregroundStyle(DSColors.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(DSColors.smoky)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .frame(width: 106, height: 32)
    }
}

#Preview {
    DSCountButton(
        count: 1,
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
}