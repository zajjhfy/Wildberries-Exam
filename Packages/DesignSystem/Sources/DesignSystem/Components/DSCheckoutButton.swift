//
//  DSCheckoutButton.swift
//  DesignSystem
//
//  Итоговая кнопка оформления заказа с суммой и количеством товаров
//

import SwiftUI

/// Итоговая кнопка оформления заказа. Показывает сумму и количество товаров слева
/// и действие «Оформить» справа. При `isExpanded` растягивается на всю ширину.
public struct DSCheckoutButton: View {

    private let action: () -> Void
    private let price: Int
    private let count: Int
    private let isExpanded: Bool
    private let isLoading: Bool

    public init(
        price: Int,
        count: Int,
        isExpanded: Bool = false,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.price = price
        self.count = count
        self.isExpanded = isExpanded
        self.isLoading = isLoading
    }

    /// Склонение слова «товар» по количеству.
    private func countString(count: Int) -> String {
        let lastDigit = count % 10
        let lastTwoDigits = count % 100

        if lastTwoDigits >= 11 && lastTwoDigits <= 19 {
            return "\(count) товаров"
        }

        switch lastDigit {
        case 1:
            return "\(count) товар"
        case 2, 3, 4:
            return "\(count) товара"
        default:
            return "\(count) товаров"
        }
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(price.formatted() + " ₽")
                            .font(.system(size: 15, weight: .bold))
                            .lineLimit(1)
                            .fixedSize()

                        Text(countString(count: count))
                            .font(.system(size: 12, weight: .regular))
                            .foregroundStyle(Color.white.opacity(0.85))
                            .lineLimit(1)
                            .fixedSize()
                    }
                    .padding(.leading, 14)

                    if isExpanded {
                        Spacer(minLength: 8)
                    }

                    Text("Оформить")
                        .font(.system(size: 16, weight: .semibold))
                        .lineLimit(1)
                        .fixedSize()
                        .padding(.trailing, 16)
                }
            }
            .frame(height: 50)
            .frame(maxWidth: isExpanded ? .infinity : nil)
            .foregroundStyle(.white)
            .background(DSColors.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .disabled(isLoading)
    }
}

#Preview {
    DSCheckoutButton(
        price: 100,
        count: 4,
        isExpanded: true
    ) {}
        .padding()
}

#Preview("Тёмная") {
    DSCheckoutButton(
        price: 100,
        count: 4,
        isExpanded: true
    ) {}
        .padding()
        .background(DSColors.screenBackground)
        .preferredColorScheme(.dark)
}