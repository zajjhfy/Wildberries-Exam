//
//  DSReviewCell+Ext.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import Foundation
import DesignSystem
import BusinessLogic

extension DSReviewCell {
    public init(_ review: ProductReview, dateText: String) {
        self.init(
            author: review.author,
            rating: review.rating,
            dateText: dateText,
            content: review.content
        )
    }
}
