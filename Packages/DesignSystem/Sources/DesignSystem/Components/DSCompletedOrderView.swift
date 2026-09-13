//
//  DSCompletedOrderView.swift
//  DesignSystem
//
//  Карточка завершённого заказа (цена, кол-во, дата, лента изображений)
//

import SwiftUI

/// Карточка завершённого заказа: стоимость, количество товаров со склонением,
/// дата доставки и ряд наложенных изображений. Не знает про сеть и модели —
/// принимает готовые элементы, стоимость, количество и дату доставки.
public struct DSCompletedOrderView: View {

    /// Элементы заказа.
    private let items: [DSOrderItem]

    /// Итоговая стоимость заказа.
    private let totalPrice: Int

    /// Количество товаров.
    private let totalItems: Int

    /// Дата доставки.
    private let deliveryDate: String

    private let imageSize: CGFloat = 47
    private let overlap: CGFloat = 12
    private let cornerRadius: CGFloat = 8
    private let maxVisibleImages = 9

    public init(
        items: [DSOrderItem],
        totalPrice: Int,
        totalItems: Int,
        deliveryDate: String
    ) {
        self.items = items
        self.totalPrice = totalPrice
        self.totalItems = totalItems
        self.deliveryDate = deliveryDate
    }

    private func productDeclension(for count: Int) -> String {
        let remainderTen = count % 10
        let remainderHundred = count % 100

        if remainderHundred >= 11 && remainderHundred <= 19 {
            return "товаров"
        }

        switch remainderTen {
        case 1:
            return "товар"
        case 2, 3, 4:
            return "товара"
        default:
            return "товаров"
        }
    }

    private var attributedText: AttributedString {
        var totalItemsText = AttributedString("\(totalItems) \(productDeclension(for: totalItems))\n")
        totalItemsText.font = DSTypography.descriptionTitle
        totalItemsText.foregroundColor = Color.secondary

        var result = AttributedString("\(totalPrice) ₽ ")
        result.font = DSTypography.descriptionTitle

        var subtitle = AttributedString("Доставили \(deliveryDate)")
        subtitle.font = DSTypography.caption

        result.append(totalItemsText)
        result.append(subtitle)
        return result
    }

    private var visibleOrders: [DSOrderItem] {
        if items.count <= maxVisibleImages {
            return items
        }
        return Array(items.prefix(maxVisibleImages - 1))
    }

    private var remainingCount: Int {
        items.count - visibleOrders.count
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

            HStack(spacing: -overlap) {
                let visibleOrders = visibleOrders
                let remainingCount = remainingCount

                ForEach(Array(visibleOrders.enumerated()), id: \.element.id) { index, order in
                    let isLast = index == visibleOrders.count - 1
                    let showOverlay = isLast && remainingCount > 0

                    productImage(
                        urlString: order.imageURL,
                        showOverlay: showOverlay,
                        overlayText: "+\(remainingCount)"
                    )
                }
                Spacer(minLength: 0)
            }
            .padding(.leading, 12)
            .frame(height: imageSize)
            .padding(.vertical, 16)
        }
        .background(DSColors.smoky)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    @ViewBuilder
    private func productImage(
        urlString: String,
        showOverlay: Bool,
        overlayText: String
    ) -> some View {
        ZStack {
            DSAsyncImage(
                urlString: urlString,
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                },
                placeholder: {
                    DSImagePlaceholder()
                }
            )
            .frame(width: imageSize, height: imageSize)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(DSColors.smoky, lineWidth: 2)
            )

            // Затемненный оверлей с количеством
            if showOverlay {
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(Color.black.opacity(0.6))
                    .overlay {
                        Text(overlayText)
                            .font(DSTypography.descriptionTitle)
                            .foregroundStyle(.white)
                            .fontWeight(.semibold)
                    }
            }
        }
        .frame(width: imageSize, height: imageSize)
    }
}

#Preview {
    DSCompletedOrderView(
        items: (1...12).map { index in
            DSOrderItem(
                id: "\(index)",
                imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
                name: "Огурец в тесте",
                weightText: "100 г"
            )
        },
        totalPrice: 100,
        totalItems: 12,
        deliveryDate: "24 августа в 08:31"
    )
    .padding()
}

#Preview("Тёмная") {
    DSCompletedOrderView(
        items: (1...12).map { index in
            DSOrderItem(
                id: "\(index)",
                imageURL: "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl",
                name: "Огурец в тесте",
                weightText: "100 г"
            )
        },
        totalPrice: 100,
        totalItems: 12,
        deliveryDate: "24 августа в 08:31"
    )
    .padding()
    .background(DSColors.screenBackground)
    .preferredColorScheme(.dark)
}
