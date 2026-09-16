//
//  OrderSuccessView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

public struct OrderSuccessView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(OrdersViewModel.self) private var ordersViewModel

    public init() {}

    public var body: some View {
        DSSuccessView(
            title: "Заказ оформлен",
            subtitle: "Товары уже в процессе сборки,\nскоро привезём!",
            onAction: {
                handleDismiss()
            },
            onClose: {
                handleDismiss()
            }
        )
        .onDisappear {
            handleDisappear()
        }
    }
}

extension OrderSuccessView {
    private var activeOrderID: String? {
        ordersViewModel.orders.first(where: { $0.status == .active })?.id
    }

    private func handleDismiss() {
        router.dismissTopSheet()
    }

    private func handleDisappear() {
        if let orderID = activeOrderID {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                router.presentSheet(.orderDetails(orderID: orderID))
            }
        }
    }
}
