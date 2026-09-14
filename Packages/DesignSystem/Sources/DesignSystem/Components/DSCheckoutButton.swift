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
            HStack(spacing: 20) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.bottom, 14.5)
                        .padding(.top, 11.5)
                } else {
                    VStack(alignment: .leading) {
                        Text(price.formatted() + "₽")
                            .font(DSTypography.summaryPrice)
                            .padding(.leading, 10)
                            .padding(.top, 7.5)
                        Text(countString(count: count))
                            .font(DSTypography.cartSubtitle)
                            .padding(.leading, 10)
                            .padding(.bottom, 7.5)
                    }

                    if isExpanded {
                        Spacer()
                    }
                    Text("Оформить")
                        .font(DSTypography.actionTitle)
                        .padding(.trailing, 18)
                        .padding(.bottom, 14.5)
                        .padding(.top, 11.5)
                }
            }
            .frame(maxWidth: isExpanded ? .infinity : nil)
            .foregroundStyle(.white)
            .background(DSColors.accentGradient)
            .cornerRadius(12)
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