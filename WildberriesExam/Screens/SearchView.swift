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

    public init() {}

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar {
                dismissSearch()
            }

            ScrollView {
                if discoveryViewModel.state == .loading && discoveryViewModel.products.isEmpty {
                    loadingView()
                } else if discoveryViewModel.products.isEmpty {
                    emptyStateView()
                } else {
                    productsGrid(discoveryViewModel.products)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(DSColors.screenBackground.ignoresSafeArea())
        .task(id: router.searchQuery) {
            let trimmed = router.searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
            await discoveryViewModel.load(.search(trimmed))
        }
    }
}

extension SearchView {
    private func topBar(onBack: @escaping () -> Void) -> some View {
        HStack {
            backButton(action: onBack)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private func backButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: "arrow.left")
                .font(.system(size: 20, weight: .regular))
                .foregroundStyle(DSColors.textPrimary)
                .frame(width: 44, height: 44, alignment: .leading)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private func loadingView() -> some View {
        HStack {
            Spacer()
            ProgressView()
                .padding(.top, 60)
            Spacer()
        }
    }

    private func emptyStateView() -> some View {
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
        .padding(.top, 40)
    }

    private func productsGrid(_ products: [CatalogProduct]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(products) { product in
                let isFav = favoritesViewModel.isFavorite(product)
                let qty = cartViewModel.quantity(for: product.id)

                DSProductCard(
                    product,
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
        .padding(.bottom, 100)
    }

    private func dismissSearch() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            router.isSearchPresented = false
            router.searchQuery = ""
        }
    }
}
