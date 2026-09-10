//
//  DSCartButton.swift
//  DesignSystem
//
//  Кнопка добавления товара в корзину с ценой и счётчиком
//

import SwiftUI

/// Кнопка добавления товара в корзину с отображением цены.
/// - Если товара в корзине нет (`count == 0`) — показывает цену и «плюс».
/// - Если товар добавлен (`count > 0`) — показывает «минус», цену и «плюс».
public struct DSCartButton: View {

    private let price: Int
    private let count: Int
    private let onIncrement: () -> Void
    private let onDecrement: () -> Void

    public init(
        price: Int,
        count: Int,
        onDecrement: @escaping () -> Void,
        onIncrement: @escaping () -> Void
    ) {
        self.price = price
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
        self.count = count
    }

    public var body: some View {
        Group {
            if count > 0 {
                activeButton
            } else {
                defaultButton
            }
        }
        .animation(.easeInOut(duration: 0.2), value: count)
    }

    @ViewBuilder
    private var activeButton: some View {
        HStack(spacing: 6) {
            Button(action: onDecrement) {
                Image(systemName: "minus")
                    .font(DSTypography.stepperIcon)
                    .frame(width: 16, height: 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(StepperButtonStyle())

            Text("\(price) ₽")
                .font(DSTypography.price)
                .frame(minWidth: 34, maxHeight: 17)
                .contentTransition(.numericText())

            Button(action: onIncrement) {
                Image(systemName: "plus")
                    .font(DSTypography.stepperIcon)
                    .frame(width: 16, height: 16)
                    .contentShape(Rectangle())
            }
            .buttonStyle(StepperButtonStyle())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .frame(height: 32)
        .background(DSColors.accentGradient)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    @ViewBuilder
    private var defaultButton: some View {
        HStack(spacing: 6) {
            Button(action: onIncrement) {
                Text("\(price) ₽")
                Image(systemName: "plus")
            }
        }
        .foregroundStyle(DSColors.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(DSColors.accentPinky)
        .clipShape(RoundedRectangle(cornerRadius: 6))
        .frame(height: 32)
    }
}

#Preview {
    DSCartButton(
        price: 150,
        count: 1,
        onDecrement: {},
        onIncrement: {}
    )
    .padding()
}
