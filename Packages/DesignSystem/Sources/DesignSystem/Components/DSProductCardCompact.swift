//
//  DSProductCardCompact.swift
//  DesignSystem
//
//  Компактная карточка товара (без цены и корзины)
//

import SwiftUI

/// Компактная карточка товара: изображение и название с весом.
/// Используется в списках заказов, где кнопки корзины не нужны.
public struct DSProductCardCompact: View {

    /// URL картинки товара.
    private let imageURL: String

    /// Название товара.
    private let name: String

    /// Вес в виде готовой строки (например «100 г»).
    private let weightText: String

    public init(
        imageURL: String,
        name: String,
        weightText: String
    ) {
        self.imageURL = imageURL
        self.name = name
        self.weightText = weightText
    }

    public var body: some View {
        VStack(alignment: .leading) {
            DSAsyncImage(
                urlString: imageURL,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 132, height: 174)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                },
                placeholder: {
                    DSImagePlaceholder()
                }
            )

            HStack(spacing: 6) {
                Text(name)
                    .font(DSTypography.cardTitle)
                Text(weightText)
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        DSProductCardCompact(
            imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
            name: "Огурец в тесте",
            weightText: "100 г"
        )
        DSProductCardCompact(
            imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl",
            name: "Хлеб",
            weightText: "300 г"
        )
    }
    .padding()
}

#Preview("Тёмная") {
    HStack(spacing: 12) {
        DSProductCardCompact(
            imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
            name: "Огурец в тесте",
            weightText: "100 г"
        )
        DSProductCardCompact(
            imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl",
            name: "Хлеб",
            weightText: "300 г"
        )
    }
    .padding()
    .background(DSColors.screenBackground)
    .preferredColorScheme(.dark)
}