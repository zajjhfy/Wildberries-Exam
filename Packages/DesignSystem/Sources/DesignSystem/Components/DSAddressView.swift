//
//  DSAddressView.swift
//  DesignSystem
//
//  Панель адреса доставки (адрес + аватар пользователя)
//

import SwiftUI

/// Панель адреса доставки: выбранный адрес с подписью «Доставка от 15 минут»
/// и кнопка-аватар пользователя. Ничего не знает про сеть и модели —
/// принимает готовые строки и колбэк перехода к профилю/заказам.
public struct DSAddressView: View {

    /// Показываемый адрес (пустая строка → «Выберите адрес»).
    private let addressText: String

    /// Первая буква имени пользователя.
    private let userInitial: String?

    /// Флаг корзины: скрывает аватар.
    private let isCart: Bool

    /// Действие по нажатию на аватар (переход к заказам/профилю).
    private let onTapProfile: () -> Void

    public init(
        addressText: String,
        userInitial: String?,
        isCart: Bool = false,
        onTapProfile: @escaping () -> Void = {}
    ) {
        self.addressText = addressText
        self.userInitial = userInitial
        self.isCart = isCart
        self.onTapProfile = onTapProfile
    }

    private var attributedText: AttributedString {
        var result = AttributedString("\(addressText.isEmpty ? "Выберите адрес" : addressText)\n")
        result.font = DSTypography.authorReviewTitle

        var subtitle = AttributedString("Доставка от 15 минут")
        subtitle.font = DSTypography.caption

        result.append(subtitle)
        return result
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                HStack(alignment: .top) {
                    Text(attributedText)
                    Image(.chevronRight)
                }
                Spacer()
                if !isCart {
                    Button(action: onTapProfile) {
                        Circle()
                            .fill(DSColors.lightGradient)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text(userInitial ?? "A")
                                    .font(DSTypography.authorReviewTitle)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .padding(.top, 8)
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
        .frame(height: 60)
        .background(DSColors.smoky)
        .cornerRadius(12)
    }
}

#Preview("Не в корзине") {
    DSAddressView(addressText: "Москва, ул. Пушкина, 1", userInitial: "И")
        .padding()
}

#Preview("В корзине") {
    DSAddressView(addressText: "Москва, ул. Пушкина, 1", userInitial: "И", isCart: true)
        .padding()
}

#Preview("Тёмная") {
    VStack(spacing: 12) {
        DSAddressView(addressText: "Москва, ул. Пушкина, 1", userInitial: "И")
        DSAddressView(addressText: "Москва, ул. Пушкина, 1", userInitial: "И", isCart: true)
    }
    .padding()
    .background(DSColors.screenBackground)
    .preferredColorScheme(.dark)
}
