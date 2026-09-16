//
//  SearchView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

public struct SearchView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(CatalogDiscoveryViewModel.self) private var discoveryViewModel
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(FavoritesViewModel.self) private var favoritesViewModel

    private let suggestions = [
        "Стакан молока с плёночкой",
        "Чоко пай",
        "Каша манная",
        "Сырники из творога",
        "Пряник тульский",
        "Сосиска в тесте",
        "Вяленая рыба"
    ]

    private let categorySuggestions = [
        "Твердые сыры",
        "Мягкие сыры",
        "Сырные продукты",
        "Молочные продукты"
    ]

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            if router.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                // Suggestions list
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Популярные запросы")
                            .font(DSTypography.descriptionTitle)
                            .foregroundStyle(DSColors.textPrimary)
                            .padding(.top, 16)
                            .padding(.horizontal, 16)

                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                router.searchQuery = suggestion
                                Task {
                                    await discoveryViewModel.load(.search(suggestion))
                                }
                            }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .font(.system(size: 14))
                                        .foregroundStyle(DSColors.textSecondary)
                                    Text(suggestion)
                                        .font(DSTypography.authorReviewTitle)
                                        .foregroundStyle(DSColors.textPrimary)
                                    Spacer()
                                    Image(systemName: "arrow.up.left")
                                        .font(.system(size: 12))
                                        .foregroundStyle(DSColors.textSecondary)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.bottom, 80)
                }
            } else {
                // Search results
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Category chips
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(categorySuggestions, id: \.self) { cat in
                                    Text(cat)
                                        .font(DSTypography.caption)
                                        .foregroundStyle(DSColors.textPrimary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(DSColors.smoky)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                        }

                        if discoveryViewModel.state == .loading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .padding(.top, 40)
                                Spacer()
                            }
                        } else if discoveryViewModel.products.isEmpty {
                            VStack(spacing: 8) {
                                Spacer(minLength: 40)
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundStyle(DSColors.textSecondary)
                                Text("Ничего не нашлось")
                                    .font(DSTypography.buttonTitle)
                                    .foregroundStyle(DSColors.textPrimary)
                                Text("Попробуйте изменить поисковый запрос")
                                    .font(DSTypography.caption)
                                    .foregroundStyle(DSColors.textSecondary)
                                Spacer(minLength: 40)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            let columns = [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ]
                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(discoveryViewModel.products) { product in
                                    let isFav = favoritesViewModel.isFavorite(product)
                                    let qty = cartViewModel.quantity(for: product.id)

                                    DSProductCard(
                                        imageURL: product.imageURL?.absoluteString ?? "",
                                        name: product.name,
                                        weightText: "\(Int(product.weight)) г",
                                        price: product.price,
                                        rating: product.rating,
                                        reviewCount: product.reviewCount,
                                        isFavorite: isFav,
                                        quantity: qty,
                                        onToggleFavorite: {
                                            Task { await favoritesViewModel.toggle(product) }
                                        },
                                        onIncrement: {
                                            Task { await cartViewModel.add(productID: product.id) }
                                        },
                                        onDecrement: {
                                            Task { await cartViewModel.remove(productID: product.id) }
                                        }
                                    )
                                    .onTapGesture {
                                        router.presentSheet(.product(id: product.id))
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 80)
                        }
                    }
                }
            }
        }
        .background(DSColors.screenBackground)
        .onChange(of: router.searchQuery) { _, newQuery in
            let trimmed = newQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            Task {
                await discoveryViewModel.load(.search(trimmed))
            }
        }
    }
}
