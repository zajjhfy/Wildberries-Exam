//
//  DSActiveOrderView.swift
//  DesignSystem
//
//  Карточка активного заказа (заголовок + лента товаров)
//

import SwiftUI

/// Элемент активного заказа — данные для компактной карточки товара.
public struct DSOrderItem: Identifiable {
    public let id: String
    public let imageURL: String
    public let name: String
    public let weightText: String

    public init(id: String, imageURL: String, name: String, weightText: String) {
        self.id = id
        self.imageURL = imageURL
        self.name = name
        self.weightText = weightText
    }
}

/// Карточка активного заказа: заголовок «Доставим через …» с адресом
/// и горизонтальная лента товаров. Не знает про сеть и модели —
/// принимает готовые элементы и строку адреса.
public struct DSActiveOrderView: View {

    /// Элементы заказа.
    private let items: [DSOrderItem]

    /// Адресная строка (подзаголовок).
    private let addressLine: String

    public init(
        items: [DSOrderItem],
        addressLine: String
    ) {
        self.items = items
        self.addressLine = addressLine
    }

    private var attributedText: AttributedString {
        var result = AttributedString("Доставим через 12 минут\n")
        result.font = DSTypography.descriptionTitle

        var subtitle = AttributedString(addressLine)
        subtitle.font = DSTypography.caption

        result.append(subtitle)
        return result
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(attributedText)
                    .padding(.leading, 12)
                    .padding(.top, 12)
                Spacer()
                Image(.chevronRight)
                    .padding(.trailing, 12)
            }
            .padding(.bottom, 12)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 8) {
                    ForEach(items) { item in
                        DSProductCardCompact(
                            imageURL: item.imageURL,
                            name: item.name,
                            weightText: item.weightText
                        )
                    }
                }
            }
            .padding(.leading, 12)
            .padding(.bottom, 14)
            .frame(height: 240)
        }
        .background(DSColors.lightGradient)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DSActiveOrderView(
        items: [
            DSOrderItem(
                id: "1",
                imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
                name: "Огурец в тесте",
                weightText: "100 г"
            ),
            DSOrderItem(
                id: "2",
                imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl",
                name: "Хлеб",
                weightText: "300 г"
            )
        ],
        addressLine: "Москва, ул. Пушкина, 1"
    )
    .padding()
}

#Preview("Тёмная") {
    DSActiveOrderView(
        items: [
            DSOrderItem(
                id: "1",
                imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
                name: "Огурец в тесте",
                weightText: "100 г"
            ),
            DSOrderItem(
                id: "2",
                imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl",
                name: "Хлеб",
                weightText: "300 г"
            )
        ],
        addressLine: "Москва, ул. Пушкина, 1"
    )
    .padding()
    .background(DSColors.screenBackground)
    .preferredColorScheme(.dark)
}
