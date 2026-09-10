//
//  DSImagePlaceholder.swift
//  DesignSystem
//
//  Плейсхолдер-заглушка для изображений
//

import SwiftUI

/// Заглушка для изображений, когда картинку не удалось получить с бэкенда.
public struct DSImagePlaceholder: View {

    /// Радиус скругления.
    public let cornerRadius: CGFloat

    public init(cornerRadius: CGFloat = 20) {
        self.cornerRadius = cornerRadius
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(DSColors.cardBackground)
            .overlay {
                Image(systemName: "photo")
                    .foregroundStyle(DSColors.textSecondary)
            }
    }
}

#Preview {
    DSImagePlaceholder()
}