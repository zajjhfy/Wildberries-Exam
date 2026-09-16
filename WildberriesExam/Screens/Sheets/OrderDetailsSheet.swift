//
//  OrderDetailsSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct OrderDetailsSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(OrdersViewModel.self) private var ordersViewModel
    @Environment(CartViewModel.self) private var cartViewModel

    private let orderID: String

    public init(orderID: String) {
        self.orderID = orderID
    }

    private var order: CustomerOrder? {
        ordersViewModel.orders.first(where: { $0.id == orderID })
    }

    private var headerTitle: String {
        if order?.status == .active {
            return "Доставим\nчерез 12 минут"
        }
        return "Доставили\n\(order?.deliveryDateText ?? "недавно")"
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header: Large 2-line title + Close button
            HStack(alignment: .top) {
                Text(headerTitle)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)
                    .lineSpacing(2)

                Spacer()

                DSCloseButton(action: {
                    router.dismissTopSheet()
                })
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 12)

            if let order = order {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {
                        // Address block (clean text, no smoky background)
                        addressSection(order: order)

                        // Products list (large 80x80 images, no smoky backgrounds)
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(order.items) { item in
                                orderItemRow(item: item)
                            }
                        }

                        // Breakdown / Summary (Итого at the top, no smoky background)
                        summarySection(order: order)
                            .padding(.top, 4)

                        // Actions
                        HStack(spacing: 12) {
                            DSButton(
                                action: {
                                    // Download receipt mock
                                },
                                buttonTitle: "Скачать чек",
                                style: .inputAddress
                            )

                            DSButton(
                                action: {
                                    repeatOrder(items: order.items)
                                },
                                buttonTitle: "Повторить заказ",
                                style: .accent
                            )
                        }
                        .padding(.top, 4)
                        .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 16)
                }
            } else {
                VStack {
                    Spacer()
                    Text("Заказ не найден")
                        .font(DSTypography.caption)
                        .foregroundStyle(DSColors.textSecondary)
                    Spacer()
                }
                .frame(height: 200)
            }
        }
    }

    private func addressSection(order: CustomerOrder) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(order.address.addressLine)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(DSColors.textPrimary)

            let details = [
                order.address.floor.map { "\($0) этаж" },
                order.address.entrance.map { "\($0) подъезд" },
                order.address.intercomCode.map { "код домофона \($0)" }
            ].compactMap { $0 }

            if !details.isEmpty {
                let suffix = order.address.comment != nil && !order.address.comment!.isEmpty ? "," : ""
                Text(details.joined(separator: ", ") + suffix)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DSColors.textSecondary)
            }

            if let comment = order.address.comment, !comment.isEmpty {
                Text(comment)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DSColors.textSecondary)
            }
        }
    }

    private func orderItemRow(item: OrderProduct) -> some View {
        HStack(alignment: .top, spacing: 14) {
            DSAsyncImage(
                urlString: item.imageURL?.absoluteString ?? "",
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                },
                placeholder: {
                    DSImagePlaceholder(cornerRadius: 16)
                        .frame(width: 104, height: 104)
                }
            )
            .frame(width: 104, height: 104)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.price) ₽, \(item.quantity) шт")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)

                (Text(item.name)
                    .foregroundColor(DSColors.textPrimary)
                 + Text(" ")
                 + Text("\(item.weight) г")
                    .foregroundColor(DSColors.textSecondary))
                .font(.system(size: 15, weight: .regular))
                .lineLimit(2)
            }
            .padding(.top, 2)

            Spacer()
        }
    }

    private func summarySection(order: CustomerOrder) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("Итого")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)
                Spacer()
                Text("\(order.totalPrice) ₽")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)
            }

            HStack {
                Text(pluralizedItems(order.totalItems))
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)
                Spacer()
                Text("\(order.orderPrice) ₽")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)
            }

            HStack {
                Text("Доставка")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)
                Spacer()
                Text(order.deliveryPrice > 0 ? "\(order.deliveryPrice) ₽" : "Бесплатно")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)
            }
        }
    }

    private func pluralizedItems(_ count: Int) -> String {
        let remainderTen = count % 10
        let remainderHundred = count % 100

        if remainderHundred >= 11 && remainderHundred <= 19 {
            return "\(count) товаров"
        }

        switch remainderTen {
        case 1:
            return "\(count) товар"
        case 2, 3, 4:
            return "\(count) товара"
        default:
            return "\(count) товаров"
        }
    }

    private func repeatOrder(items: [OrderProduct]) {
        Task {
            for item in items {
                await cartViewModel.add(productID: item.id)
            }
            router.presentSheet(.cart)
        }
    }
}
