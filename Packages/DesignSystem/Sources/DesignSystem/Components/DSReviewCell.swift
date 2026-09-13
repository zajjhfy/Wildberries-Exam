//
//  DSReviewCell.swift
//  DesignSystem
//
//  Ячейка отзыва (звёзды, автор, дата, текст)
//

import SwiftUI

/// Ячейка отзыва: рейтинг (звёзды), автор, дата и текст.
/// Не знает про сеть и модели — принимает готовые строки и рейтинг.
public struct DSReviewCell: View {

    /// Имя автора отзыва.
    private let author: String

    /// Оценка отзыва (1…5).
    private let rating: Int

    /// Дата отзыва в готовом виде (например «13 сентября 2026»).
    private let dateText: String

    /// Текст отзыва.
    private let content: String

    public init(
        author: String,
        rating: Int,
        dateText: String,
        content: String
    ) {
        self.author = author
        self.rating = rating
        self.dateText = dateText
        self.content = content
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 2) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: "star.fill")
                        .foregroundStyle(star <= rating ? .black : DSColors.textSecondary)
                        .font(.system(size: 12))
                }
                Text("\(author),")
                    .font(DSTypography.authorReviewTitle)
                    .foregroundStyle(DSColors.textPrimary)
                    .padding(.leading, 6)
                Text(dateText)
                    .font(DSTypography.reviewMeta)
                    .foregroundStyle(DSColors.textPrimary)
                Spacer()
            }

            Text(content)
                .font(DSTypography.cardTitle)
                .foregroundStyle(DSColors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(12)
        .background(DSColors.smoky)
        .cornerRadius(12)
    }
}

#Preview {
    DSReviewCell(
        author: "Иван",
        rating: 4,
        dateText: "13 сентября 2026",
        content: "Отличный товар, рекомендую!"
    )
    .padding()
}