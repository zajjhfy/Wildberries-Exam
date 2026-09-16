//
//  DSOrders+Ext.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import Foundation
import DesignSystem
import BusinessLogic

extension DSOrderItem {
    public init(_ product: OrderProduct) {
        self.init(
            id: product.id,
            imageURL: product.imageURL?.absoluteString ?? "",
            name: product.name,
            weightText: "\(product.weight) г"
        )
    }
}

extension DSActiveOrderView {
    public init(_ order: CustomerOrder) {
        self.init(
            items: order.items.map(DSOrderItem.init),
            addressLine: order.address.addressLine
        )
    }
}

extension DSCompletedOrderView {
    public init(_ order: CustomerOrder) {
        self.init(
            items: order.items.map(DSOrderItem.init),
            totalPrice: order.totalPrice,
            totalItems: order.totalItems,
            deliveryDate: order.deliveryDateText ?? "недавно"
        )
    }
}
