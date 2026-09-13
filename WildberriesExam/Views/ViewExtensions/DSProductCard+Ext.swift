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
    init(_ product: CatalogProduct,
         onIncrement: @escaping () -> Void,
         onDecrement: @escaping () -> Void,
         onToggleFavorite: @escaping () -> Void
    ) {
        var urlString: String
        
        if let url = product.imageURL {
            urlString = url.absoluteString
        } else {
            urlString = "https://eat-and-pay.t02.ru/uploads/eats-jxl/echpochmak.jxl"
        }
        
        /*
         Почему imageURL не опционал или почему CatalogProduct imageURL: URL? а не String?
         Согласуйте типы данных друг с другом, чтобы мне не нужно было String(Int()) и т.д.
         */
        
        self.init(imageURL: urlString, name: product.name, weightText: String(Int(product.weight)), price: product.price, rating: product.rating, reviewCount: product.reviewCount, isFavorite: product.isFavorite, quantity: 0, onToggleFavorite: onToggleFavorite, onIncrement: onIncrement, onDecrement: onDecrement)
    }
}
