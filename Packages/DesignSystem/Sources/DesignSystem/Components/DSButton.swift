//
//  DSButton.swift
//  DesignSystem
//
//  Универсальная основная кнопка с разными стилями
//

import SwiftUI

/// ## Что это
/// Универсальная основная кнопка дизайн-системы. Обычно это **главное действие**
/// на экране: «В корзину», «Оставить отзыв», «Выбрать адрес», «Сохранить
/// изменения». Размер кнопка набирает сама (`.frame(maxWidth: .infinity)`),
/// поэтому её достаточно обернуть в отступы.
///
/// ## Когда использовать
/// Используй её для **одного выделенного действия** на экране
/// или в паре «основная + второстепенная» кнопка (см. стили ниже).
///
/// Не используй `DSButton` для:
/// - маленьких интерактивных элементов внутри карточек (там `DSCartButton`, `DSCountButton`);
/// - быстрых иконок-действий (`CloseButton`, map-кнопки);
/// - текстовых вкладок (`TextTabBar`) и строки поиска (`SearchBar`).
///
/// ## Параметры
/// - `action` — действие по нажатию.
/// - `buttonTitle` — текст на кнопке (по умолчанию «В корзину»).
/// - `style` — внешний вид (по умолчанию `.accent`).
/// - `isLoading` — показать спиннер вместо текста (для сетевых вызовов).
/// - `disabled` — заблокировать кнопку (серый градиент).
///
/// ## Стили
/// Меняется через `style:`. При блокировке (`disabled`) любой стиль
/// превращается в серый градиент `DSColors.grayGradient`.
public struct DSButton: View {

    /// Стили внешнего вида кнопки
    public enum Style {
        /// **Основная** фиолетовая кнопка: градиент `accentGradient`, белый текст.
        /// Главное действие на экране — «В корзину», «Оставить отзыв», «Привезти сюда».
        case accent

        /// Светлая «мягкая» кнопка: градиент `lightGradient`, тёмный текст.
        /// Второстепенное действие на светлом фоне — например «Написать отзыв».
        case light

        /// Белая кнопка с фиолетовым текстом — на ярком/градиентном фоне
        /// (например «Закрыть» на экране успеха `SuccessView`).
        case white

        /// Белая кнопка с чёрным текстом и розовой рамкой — **второстепенная
        /// кнопка в паре** с основной (`.accent`). «Ввести другой», «Скачать чек».
        case inputAddress
    }

    private let action: () -> Void
    private let buttonTitle: String
    private let style: Style
    private let disabled: Bool
    private let isLoading: Bool

    /// Одинокая основная кнопка:
    /// ```swift
    /// DSButton(action: { addToCart() }, buttonTitle: "В корзину")
    /// ```
    ///
    /// Пара «основная + второстепенная» (как на карте адреса):
    /// ```swift
    /// HStack {
    ///     DSButton(action: manualAction, buttonTitle: "Ввести другой", style: .inputAddress)
    ///     DSButton(action: selectAction, buttonTitle: "Выбрать адрес", style: .accent)
    /// }
    /// ```
    ///
    /// С блокировкой и лоадером (пока сохранение, показываем спиннер):
    /// ```swift
    /// DSButton(
    ///     action: { save() },
    ///     buttonTitle: "Сохранить изменения",
    ///     isLoading: viewModel.isLoading,
    ///     disabled: !viewModel.hasChanges
    /// )
    /// ```
    public init(
        action: @escaping () -> Void,
        buttonTitle: String = "В корзину",
        style: Style = .accent,
        isLoading: Bool = false,
        disabled: Bool = false
    ) {
        self.action = action
        self.buttonTitle = buttonTitle
        self.style = style
        self.isLoading = isLoading
        self.disabled = disabled
    }

    private func getBackground(style: Style) -> LinearGradient {
        if disabled {
            return DSColors.grayGradient
        }
        switch style {
        case .accent:
            return DSColors.accentGradient
        case .light:
            return DSColors.lightGradient
        case .white:
            return .linearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing)
        case .inputAddress:
            return .linearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing)
        }
    }

    private func getForeground(style: Style) -> Color {
        if disabled {
            return .gray
        }
        switch style {
        case .accent:
            return .white
        case .light:
            return .black
        case .white:
            return DSColors.accent
        case .inputAddress:
            return .black
        }
    }

    private func getBorder(style: Style) -> Color {
        switch style {
        case .accent, .light, .white:
            return .clear
        case .inputAddress:
            return DSColors.accentPinky
        }
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(buttonTitle)
                        .font(DSTypography.buttonTitle)
                }
            }
            .frame(maxWidth: .infinity)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .foregroundStyle(getForeground(style: style))
            .padding(.vertical, 13)
            .background(getBackground(style: style))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(getBorder(style: style), lineWidth: 1.5)
            )
        }
        .disabled(disabled)
    }
}

#Preview {
    DSButton() {}
        .padding()
}
