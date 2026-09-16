//
//  DSProductCard+Ext.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import Foundation
import DesignSystem
import BusinessLogic

extension DSProductCard {
    public init(
        _ product: CatalogProduct,
        isFavorite: Bool = false,
        quantity: Int = 0,
        onToggleFavorite: @escaping () -> Void,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void
    ) {
        let urlString = product.imageURL?.absoluteString ?? "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl"
        self.init(
            imageURL: urlString,
            name: product.name,
            weightText: "\(Int(product.weight)) г",
            price: product.price,
            rating: product.rating,
            reviewCount: product.reviewCount,
            isFavorite: isFavorite,
            quantity: quantity,
            onToggleFavorite: onToggleFavorite,
            onIncrement: onIncrement,
            onDecrement: onDecrement
        )
    }

    public init(
        _ product: CatalogProduct,
        onIncrement: @escaping () -> Void,
        onDecrement: @escaping () -> Void,
        onToggleFavorite: @escaping () -> Void
    ) {
        self.init(
            product,
            isFavorite: product.isFavorite,
            quantity: 0,
            onToggleFavorite: onToggleFavorite,
            onIncrement: onIncrement,
            onDecrement: onDecrement
        )
    }
}
