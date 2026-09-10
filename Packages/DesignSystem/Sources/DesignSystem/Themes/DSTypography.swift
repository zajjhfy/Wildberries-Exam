//
//  DSTypography.swift
//  DesignSystem
//
//  Типографика дизайн-системы
//

import SwiftUI

/// Типографика дизайн-системы
///
/// Использует системные шрифты с фиксированными размерами и весами.
/// При подключении кастомных шрифтов достаточно заменить `.system` на `.custom(_:size:)`.
public enum DSTypography {

    // MARK: - Headlines

    /// Название продукта в карточке товара (14, bold).
    public static let cardTitle: Font = .system(size: 14, weight: .bold)

    /// Заголовок на деталях карточки товара (26, bold).
    public static let cardDetailsTitle: Font = .system(size: 26, weight: .bold)

    /// Крупный заголовок экрана (32, bold).
    public static let hugeTitle: Font = .system(size: 32, weight: .bold)

    /// Имя пользователя (38, bold).
    public static let userName: Font = .system(size: 38, weight: .bold)

    /// Метаданные отзыва: имя автора и дата (14, medium).
    public static let reviewMeta: Font = .system(size: 14, weight: .medium)

    /// Большая оценка (рейтинг товара) (94, light).
    public static let estimationHuge: Font = .system(size: 94, weight: .light)

    /// Заголовок описания (20, bold).
    public static let descriptionTitle: Font = .system(size: 20, weight: .bold)

    /// Заголовок поиска (18, bold).
    public static let searchTitle: Font = .system(size: 18, weight: .bold)

    /// Заголовок экрана успеха (56, light).
    public static let reviewSuccessTitle: Font = .system(size: 56, weight: .light)

    /// Подзаголовок экрана успеха (22, light).
    public static let reviewSuccessSubtitle: Font = .system(size: 22, weight: .light)

    /// Заголовок адреса (17, bold).
    public static let addressTitle: Font = .system(size: 17, weight: .bold)

    /// Заголовок адреса на карте (24, bold).
    public static let addressMapTitle: Font = .system(size: 24, weight: .bold)

    // MARK: - Body

    /// Второстепенный текст (14, regular).
    public static let caption: Font = .system(size: 14, weight: .regular)

    /// Body Large (16, regular).
    public static let bodyLarge: Font = .system(size: 16, weight: .regular)

    /// Подзаголовок корзины (14, semibold).
    public static let cartSubtitle: Font = .system(size: 14, weight: .semibold)

    /// Название вкладок в tab bar (18, bold).
    public static let tabBarTitle: Font = .system(size: 18, weight: .bold)

    // MARK: - Button

    /// Текст основной кнопки `DSButton` (24, semibold).
    public static let buttonTitle: Font = .system(size: 24, weight: .semibold)

    // MARK: - Product / Cart

    /// Цена товара в кнопке добавления в корзину (14, bold).
    public static let price: Font = .system(size: 14, weight: .bold)

    /// Иконки степпера «плюс/минус» в кнопках количества товара (16, bold).
    public static let stepperIcon: Font = .system(size: 16, weight: .bold)

    /// Крупная цена в итоговой кнопке оформления заказа (18, semibold).
    public static let summaryPrice: Font = .system(size: 18, weight: .semibold)

    /// Текст действия в итоговой кнопке оформления заказа (20, semibold).
    public static let actionTitle: Font = .system(size: 20, weight: .semibold)
}