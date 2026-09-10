//
//  DSCategoryCard.swift
//  DesignSystem
//
//  Карточка категории (каталог)
//

import SwiftUI

/// Карточка категории каталога: изображение с градиентной подложкой
/// и названием категории. Ширина задаётся сеткой (`LazyVGrid`),
/// высота — фиксированная.
public struct DSCategoryCard: View {

    /// Название категории.
    private let title: String

    /// URL изображения категории.
    private let imageURL: String

    public init(title: String, imageURL: String) {
        self.title = title
        self.imageURL = imageURL
    }

    public var body: some View {
        DSAsyncImage(
            urlString: imageURL,
            content: { image in
                styled(image.resizable())
            },
            placeholder: {
                styled(Color(DSColors.cardBackground))
            }
        )
    }

    /// Общая обводка (градиент + название) для контента и плейсхолдера.
    private func styled<CardContent: View>(_ content: CardContent) -> some View {
        content
            .overlay {
                DSColors.catalogGradient
                    .padding(.top, 48)
                    .background(.ultraThinMaterial.opacity(0.1))
            }
            .overlay(alignment: .bottomLeading) {
                Text(title)
                    .font(DSTypography.cardTitle)
                    .foregroundStyle(DSColors.textPrimary)
                    .lineSpacing(1)
                    .padding(.top, 48)
                    .padding(.horizontal, 8)
                    .padding(.bottom, 6)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 132)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    LazyVGrid(
        columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
        spacing: 8
    ) {
        DSCategoryCard(
            title: "Фермерские товары",
            imageURL: "https://picsum.photos/200/200"
        )
        DSCategoryCard(
            title: "Напитки",
            imageURL: "https://picsum.photos/200/200"
        )
    }
    .padding()
}