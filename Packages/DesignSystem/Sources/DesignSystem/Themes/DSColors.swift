//
//  DSColors.swift
//  DesignSystem
//
//  Цветовая палитра дизайн-системы
//
//  Каждый токен означает ровно одно назначение. Если цвет кажется
//  одинаковым — это сознательно один и тот же токен, не дубликат.
//

import SwiftUI

/// Цветовая палитра дизайн-системы
public enum DSColors {

    // MARK: - Accent

    /// Брендовый фиолетовый (основной акцент).
    /// Белый текст на белой кнопке, фон сплэш-экрана.
    public static let accent = Color(
        red: 154 / 255,
        green: 16 / 255,
        blue: 240 / 255
    )

    /// Ярко-розовый цвет иконки «плюс» (кнопка добавления в корзину).
    public static let plusPinky = Color(
        red: 191 / 255,
        green: 34 / 255,
        blue: 225 / 255
    )

    /// Светло-розовый фон кнопки добавления в корзину и рамка второстепенной кнопки.
    public static let accentPinky = Color(
        red: 254 / 255,
        green: 241 / 255,
        blue: 251 / 255
    )

    // MARK: - Search

    /// Полупрозрачный серо-голубой фон строки поиска и кнопки поиска.
    public static let searchBackground = Color(
        red: 246 / 255,
        green: 246 / 255,
        blue: 250 / 255,
        opacity: 0.76
    )

    // MARK: - Gradient

    /// Градиент основной (фиолетовой) кнопки добавления в корзину.
    public static let accentGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.93, green: 0.24, blue: 0.79), location: 0.0049),
            .init(color: Color(red: 0.87, green: 0.20, blue: 0.82), location: 0.1488),
            .init(color: Color(red: 0.82, green: 0.17, blue: 0.85), location: 0.2927),
            .init(color: Color(red: 0.75, green: 0.13, blue: 0.88), location: 0.4314),
            .init(color: Color(red: 0.68, green: 0.10, blue: 0.91), location: 0.5702),
            .init(color: Color(red: 0.60, green: 0.06, blue: 0.94), location: 0.7089),
            .init(color: Color(red: 0.51, green: 0.02, blue: 0.97), location: 0.8476),
            .init(color: Color(red: 0.40, green: 0.00, blue: 1.00), location: 0.9915),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Светлый градиент второстепенной кнопки (например «Написать отзыв»).
    public static let lightGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.996, green: 0.945, blue: 0.984), location: 0.0049),
            .init(color: Color(red: 0.992, green: 0.945, blue: 0.988), location: 0.1488),
            .init(color: Color(red: 0.988, green: 0.941, blue: 0.988), location: 0.2927),
            .init(color: Color(red: 0.984, green: 0.941, blue: 0.992), location: 0.4314),
            .init(color: Color(red: 0.976, green: 0.937, blue: 0.992), location: 0.5702),
            .init(color: Color(red: 0.973, green: 0.933, blue: 0.996), location: 0.7089),
            .init(color: Color(red: 0.965, green: 0.933, blue: 0.996), location: 0.8476),
            .init(color: Color(red: 0.957, green: 0.929, blue: 1.000), location: 0.9915),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Серый градиент недоступной (disabled) кнопки.
    public static let grayGradient = LinearGradient(
        colors: [
            Color(red: 240 / 255, green: 236 / 255, blue: 244 / 255),
            Color(red: 240 / 255, green: 236 / 255, blue: 244 / 255),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Градиент подложки карточек каталога.
    public static let catalogGradient = LinearGradient(
        stops: [
            .init(color: Color(red: 0.965, green: 0.965, blue: 0.980), location: 0.0),
            .init(color: Color(red: 0.965, green: 0.965, blue: 0.980), location: 0.327),
            .init(color: Color(red: 0.976, green: 0.976, blue: 0.988).opacity(0.643), location: 0.577),
            .init(color: Color.white.opacity(0), location: 1.0),
        ],
        startPoint: .bottom,
        endPoint: .top
    )

    // MARK: - Text

    /// Основной цвет текста.
    public static let textPrimary = Color(
        red: 0.13,
        green: 0.13,
        blue: 0.13
    )

    /// Второстепенный цвет текста (подписи, плейсхолдеры).
    public static let textSecondary = Color(
        red: 151 / 255,
        green: 151 / 255,
        blue: 175 / 255
    )

    // MARK: - Background

    /// Нейтральный серый фон карточек и плейсхолдеров изображений (без синего оттенка).
    public static let cardBackground = Color(
        red: 0.97,
        green: 0.97,
        blue: 0.97
    )

    /// Серый с холодным (голубым) оттенком для интерактивных подложек —
    /// кнопки количества, ячейки отзывов.
    public static let smoky = Color(
        red: 246 / 255,
        green: 246 / 255,
        blue: 250 / 255
    )

    /// Основной фон экрана.
    public static let screenBackground = Color.white

    /// Полупрозрачный белый текст на градиентном фоне экрана успеха.
    public static let reviewSuccessSubtitle = Color(
        red: 1,
        green: 1,
        blue: 1,
        opacity: 0.7
    )
}