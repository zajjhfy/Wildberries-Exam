//
//  DSProductCard.swift
//  DesignSystem
//
//  Карточка товара (каталог) с избранным и кнопкой добавления в корзину
//

import SwiftUI

/// Карточка товара для каталога.
///
/// «Глупая» переиспользуемая view: не знает про сервисы, SwiftData и сетевые
/// модели. Принимает готовые данные и колбэки действий, поэтому может быть
/// встроена в любой список товаров.
public struct DSProductCard: View {

    /// URL картинки товара.
    private let imageURL: String

    /// Название товара.
    private let name: String

    /// Вес в виде готовой строки (например «80 г»).
    private let weightText: String

    /// Базовая цена за единицу.
    private let price: Int

    /// Рейтинг товара (дробный).
    private let rating: Double

    /// Количество отзывов.
    private let reviewCount: Int

    /// Флаг «в избранном».
    private let isFavorite: Bool

    /// Количество в корзине.
    private let quantity: Int

    /// Действие по нажатию на избранное.
    private let onToggleFavorite: () -> Void

    /// Действие «добавить» (плюс).
    private let onIncrement: () -> Void

    /// Действие «убрать» (минус).
    private let onDecrement: () -> Void

    public init(
        imageURL: String,
        name: String,
        weightText: String,
        price: Int,
        rating: Double,
        reviewCount: Int,
        isFavorite: Bool,
        quantity: Int,
        onToggleFavorite: @escaping () -> Void,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        self.imageURL = imageURL
        self.name = name
        self.weightText = weightText
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.isFavorite = isFavorite
        self.quantity = quantity
        self.onToggleFavorite = onToggleFavorite
        self.onIncrement = onIncrement
        self.onDecrement = onDecrement
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSAsyncImage(
                urlString: imageURL,
                content: { image in
                    image
                        .resizable()
                        .scaledToFill()
                },
                placeholder: {
                    DSImagePlaceholder(cornerRadius: 20)
                }
            )
            .frame(width: 174, height: 256)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(alignment: .topTrailing) {
                Button(action: onToggleFavorite) {
                    if isFavorite {
                        Image(.isFavorite)
                            .padding(10)
                    } else {
                        Image(.heartCart)
                            .padding(10)
                    }
                }
            }

            HStack(spacing: 6) {
                Text(name)
                    .font(DSTypography.cardTitle)
                Text(weightText)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }

            HStack(spacing: 2) {
                Image(.star)
                    .renderingMode(.template)
                    .foregroundStyle(Color.primary)

                Text(rating.dsRatingString)
                    .font(DSTypography.caption)

                Image(.messages)
                    .renderingMode(.template)
                    .foregroundStyle(Color.primary)

                Text(reviewCount.formatted())
                    .font(DSTypography.caption)
            }
            .padding(.bottom, 12)

            DSCartButton(
                price: displayedPrice,
                count: quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
    }

    /// Итоговая цена, показываемая в кнопке корзины.
    /// Если товар добавлен — сумма за всё количество.
    private var displayedPrice: Int {
        quantity > 0 ? price * quantity : price
    }
}

#Preview("Не в корзине") {
    DSProductCard(
        imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
        name: "Огурец в тесте",
        weightText: "80 г",
        price: 750,
        rating: 3.8,
        reviewCount: 1356,
        isFavorite: false,
        quantity: 0,
        onToggleFavorite: {},
        onIncrement: {},
        onDecrement: {}
    )
    .frame(width: 200)
    .padding()
}

#Preview("В корзине") {
    DSProductCard(
        imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
        name: "Огурец в тесте",
        weightText: "80 г",
        price: 750,
        rating: 4.5,
        reviewCount: 1356,
        isFavorite: true,
        quantity: 3,
        onToggleFavorite: {},
        onIncrement: {},
        onDecrement: {}
    )
    .frame(width: 200)
    .padding()
}
