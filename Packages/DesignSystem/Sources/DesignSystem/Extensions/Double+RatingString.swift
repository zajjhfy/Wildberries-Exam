//
//  Double+RatingString.swift
//  DesignSystem
//
//  Форматирование рейтинга для отображения (например «4.5»)
//

import Foundation

public extension Double {

    /// Рейтинг в виде строки с десятичной точкой.
    /// - Одна цифра после точки максимум.
    /// - Без лишнего нуля в дробной части (`4.5`, `4`).
    var dsRatingString: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.decimalSeparator = "."
        formatter.maximumFractionDigits = 1
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}