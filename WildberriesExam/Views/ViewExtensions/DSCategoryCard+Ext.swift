//
//  DSCategoryCard+Ext.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import Foundation
import DesignSystem
import BusinessLogic

extension DSCategoryCard {
    init(_ category: CatalogCategory) {
        var urlString: String
        
        if let imageURL = category.imageURL {
            urlString = imageURL.absoluteString
        } else {
            urlString = "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl"
        }
        
        self.init(title: category.name, imageURL: urlString)
    }
}
