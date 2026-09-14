//
//  DSColors.swift
//  DesignSystem
//
//  Цветовая палитра дизайн-системы
//
//  Каждый токен означает ровно одно назначение. Если цвет кажется
//  одинаковым — это сознательно один и тот же токен, не дубликат.
//
//  Токены, зависящие от темы, строятся через `adaptive(light:dark:)`:
//  они автоматически переключаются между светлой и тёмной темой.
//  Брендовые цвета (`accent`, `plusPinky`, `accentGradient`) фиксированы.
//

import SwiftUI
import UIKit

/// Цветовая палитра дизайн-системы
public enum DSColors {

    /// Строит адаптивный цвет: светлый/тёмный варианты по `colorScheme`.
    private static func adaptive(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        })
    }

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
    public static let accentPinky = adaptive(
        light: UIColor(red: 254 / 255, green: 241 / 255, blue: 251 / 255, alpha: 1),
        dark: UIColor(red: 0.30, green: 0.14, blue: 0.34, alpha: 1)
    )

    // MARK: - Search

    /// Полупрозрачный серо-голубой фон строки поиска и кнопки поиска.
    public static let searchBackground = adaptive(
        light: UIColor(red: 246 / 255, green: 246 / 255, blue: 250 / 255, alpha: 0.76),
        dark: UIColor(red: 0.14, green: 0.14, blue: 0.17, alpha: 0.76)
    )

    // MARK: - Gradient

    /// Градиент основной (фиолетовой) кнопки добавления в корзину.
    /// Брендовый — одинаковый в обеих темах.
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
            .init(color: adaptive(light: UIColor(red: 0.996, green: 0.945, blue: 0.984, alpha: 1), dark: UIColor(red: 0.18, green: 0.10, blue: 0.21, alpha: 1)), location: 0.0049),
            .init(color: adaptive(light: UIColor(red: 0.992, green: 0.945, blue: 0.988, alpha: 1), dark: UIColor(red: 0.19, green: 0.11, blue: 0.22, alpha: 1)), location: 0.1488),
            .init(color: adaptive(light: UIColor(red: 0.988, green: 0.941, blue: 0.988, alpha: 1), dark: UIColor(red: 0.20, green: 0.12, blue: 0.23, alpha: 1)), location: 0.2927),
            .init(color: adaptive(light: UIColor(red: 0.984, green: 0.941, blue: 0.992, alpha: 1), dark: UIColor(red: 0.21, green: 0.13, blue: 0.24, alpha: 1)), location: 0.4314),
            .init(color: adaptive(light: UIColor(red: 0.976, green: 0.937, blue: 0.992, alpha: 1), dark: UIColor(red: 0.22, green: 0.14, blue: 0.25, alpha: 1)), location: 0.5702),
            .init(color: adaptive(light: UIColor(red: 0.973, green: 0.933, blue: 0.996, alpha: 1), dark: UIColor(red: 0.23, green: 0.15, blue: 0.26, alpha: 1)), location: 0.7089),
            .init(color: adaptive(light: UIColor(red: 0.965, green: 0.933, blue: 0.996, alpha: 1), dark: UIColor(red: 0.24, green: 0.16, blue: 0.27, alpha: 1)), location: 0.8476),
            .init(color: adaptive(light: UIColor(red: 0.957, green: 0.929, blue: 1.000, alpha: 1), dark: UIColor(red: 0.25, green: 0.17, blue: 0.28, alpha: 1)), location: 0.9915),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    /// Серый градиент недоступной (disabled) кнопки.
    public static let grayGradient = LinearGradient(
        colors: [
            adaptive(light: UIColor(red: 240 / 255, green: 236 / 255, blue: 244 / 255, alpha: 1), dark: UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1)),
            adaptive(light: UIColor(red: 240 / 255, green: 236 / 255, blue: 244 / 255, alpha: 1), dark: UIColor(red: 0.20, green: 0.20, blue: 0.22, alpha: 1)),
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Градиент подложки карточек каталога.
    public static let catalogGradient = LinearGradient(
        stops: [
            .init(color: adaptive(light: UIColor(red: 0.965, green: 0.965, blue: 0.980, alpha: 1), dark: UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1)), location: 0.0),
            .init(color: adaptive(light: UIColor(red: 0.965, green: 0.965, blue: 0.980, alpha: 1), dark: UIColor(red: 0.15, green: 0.15, blue: 0.17, alpha: 1)), location: 0.327),
            .init(color: adaptive(light: UIColor(red: 0.976, green: 0.976, blue: 0.988, alpha: 0.643), dark: UIColor(red: 0.17, green: 0.17, blue: 0.19, alpha: 0.643)), location: 0.577),
            .init(color: adaptive(light: UIColor(red: 1, green: 1, blue: 1, alpha: 0), dark: UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 0)), location: 1.0),
        ],
        startPoint: .bottom,
        endPoint: .top
    )

    /// Градиент для фейда у текстового таб бара.
    public static let textTabBarGradient = LinearGradient(
        stops: [
            .init(color: adaptive(light: UIColor(red: 1, green: 1, blue: 1, alpha: 0), dark: UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 0)), location: 0),
            .init(color: adaptive(light: UIColor(red: 1, green: 1, blue: 1, alpha: 1), dark: UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1)), location: 0.8029),
        ],
        startPoint: .leading,
        endPoint: .trailing
    )

    // MARK: - Text

    /// Основной цвет текста.
    public static let textPrimary = adaptive(
        light: UIColor(red: 0.13, green: 0.13, blue: 0.13, alpha: 1),
        dark: UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)
    )

    /// Второстепенный цвет текста (подписи, плейсхолдеры).
    public static let textSecondary = adaptive(
        light: UIColor(red: 151 / 255, green: 151 / 255, blue: 175 / 255, alpha: 1),
        dark: UIColor(red: 0.64, green: 0.64, blue: 0.72, alpha: 1)
    )

    // MARK: - Background

    /// Нейтральный серый фон карточек и плейсхолдеров изображений (без синего оттенка).
    public static let cardBackground = adaptive(
        light: UIColor(red: 0.97, green: 0.97, blue: 0.97, alpha: 1),
        dark: UIColor(red: 0.13, green: 0.13, blue: 0.15, alpha: 1)
    )

    /// Серый с холодным (голубым) оттенком для интерактивных подложек —
    /// кнопки количества, ячейки отзывов.
    public static let smoky = adaptive(
        light: UIColor(red: 246 / 255, green: 246 / 255, blue: 250 / 255, alpha: 1),
        dark: UIColor(red: 0.14, green: 0.14, blue: 0.17, alpha: 1)
    )

    /// Основной фон экрана.
    public static let screenBackground = adaptive(
        light: UIColor(red: 1, green: 1, blue: 1, alpha: 1),
        dark: UIColor(red: 0.07, green: 0.07, blue: 0.09, alpha: 1)
    )

    /// Полупрозрачный белый текст на градиентном фоне экрана успеха.
    public static let reviewSuccessSubtitle = Color(
        red: 1,
        green: 1,
        blue: 1,
        opacity: 0.7
    )
}