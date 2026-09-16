//
//  CatalogView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct CatalogView: View {
    public enum Tab: Int, CaseIterable {
        case forYou, catalog, discounts, favorites, orderedBefore

        public var title: String {
            switch self {
            case .forYou: "Для тебя"
            case .catalog: "Каталог"
            case .discounts: "Скидки"
            case .favorites: "Избранное"
            case .orderedBefore: "Уже заказывали"
            }
        }
    }

    @EnvironmentObject private var router: AppRouter
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(FavoritesViewModel.self) private var favoritesViewModel
    @Environment(CatalogDiscoveryViewModel.self) private var discoveryViewModel

    @State private var viewModel: CatalogViewModel
    @State private var selectedTab: Tab = .forYou
    @State private var hasAppeared: Bool = false

    private var prefetchThreshold: CGFloat = 400

    public init(viewModel: CatalogViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Tab bar
            DSTextTabBar(
                selectedIndex: Binding(
                    get: { selectedTab.rawValue },
                    set: { selectedTab = Tab(rawValue: $0) ?? .forYou }
                ),
                tabs: Tab.allCases.map(\.title)
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            // Content
            ScrollView {
                switch selectedTab {
                case .forYou:
                    forYouContent()
                case .catalog:
                    catalogContent()
                case .discounts:
                    discountsContent()
                case .favorites:
                    favoritesContent()
                case .orderedBefore:
                    orderedBeforeContent()
                }
            }
            .contentMargins(.bottom, 80, for: .scrollContent)
            .onScrollGeometryChange(for: Bool.self) { geometry in
                let distanceFromBottom = geometry.contentSize.height - geometry.visibleRect.maxY
                return distanceFromBottom < prefetchThreshold
            } action: { wasNearBottom, isNowNearBottom in
                guard isNowNearBottom, !wasNearBottom, selectedTab == .forYou else { return }
                Task { await viewModel.loadNextPage() }
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            handleTabChange(newTab)
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                Task {
                    if viewModel.selectedCategoryID != nil {
                        await viewModel.selectCategory(nil)
                    } else if viewModel.state != .loaded {
                        await viewModel.refresh()
                    }
                }
            } else if selectedTab == .forYou && viewModel.selectedCategoryID != nil {
                // Ensure returning to forYou tab resets category filter
                Task { await viewModel.selectCategory(nil) }
            }
        }
    }

    private func handleTabChange(_ tab: Tab) {
        Task {
            switch tab {
            case .forYou:
                if viewModel.selectedCategoryID != nil {
                    await viewModel.selectCategory(nil)
                }
            case .catalog:
                if viewModel.categories.isEmpty {
                    await viewModel.refresh()
                }
            case .discounts:
                await discoveryViewModel.load(.discounts)
            case .favorites:
                await favoritesViewModel.load()
            case .orderedBefore:
                await discoveryViewModel.load(.orderedBefore)
            }
        }
    }
}

// MARK: - Subviews
extension CatalogView {
    @ViewBuilder
    private func forYouContent() -> some View {
        if viewModel.state == .loading && viewModel.products.isEmpty {
            shimmerGrid()
        } else if case let .failed(error) = viewModel.state, viewModel.products.isEmpty {
            errorView(error) {
                Task { await viewModel.refresh() }
            }
        } else {
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(Array(viewModel.products.enumerated()), id: \.element.id) { index, product in
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
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    @ViewBuilder
    private func catalogContent() -> some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 3)

        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.categories) { category in
                Button {
                    router.push(.category(id: category.id, title: category.name))
                } label: {
                    DSCategoryCard(category)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func discountsContent() -> some View {
        if discoveryViewModel.state == .loading && discoveryViewModel.products.isEmpty {
            shimmerGrid()
        } else if discoveryViewModel.products.isEmpty {
            emptyState(title: "Скидок пока нет", subtitle: "Загляните сюда позже")
        } else {
            productGrid(discoveryViewModel.products)
        }
    }

    @ViewBuilder
    private func favoritesContent() -> some View {
        if favoritesViewModel.state == .loading && favoritesViewModel.products.isEmpty {
            shimmerGrid()
        } else if favoritesViewModel.products.isEmpty {
            emptyState(title: "В избранном пока пусто", subtitle: "Нажмите на сердечко на карточке товара, чтобы добавить его сюда")
        } else {
            productGrid(favoritesViewModel.products)
        }
    }

    @ViewBuilder
    private func orderedBeforeContent() -> some View {
        if discoveryViewModel.state == .loading && discoveryViewModel.products.isEmpty {
            shimmerGrid()
        } else if discoveryViewModel.products.isEmpty {
            emptyState(title: "Вы ещё ничего не заказывали", subtitle: "Здесь появятся товары из ваших предыдущих заказов")
        } else {
            productGrid(discoveryViewModel.products)
        }
    }

    @ViewBuilder
    private func productGrid(_ products: [CatalogProduct]) -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(products) { product in
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
    }

    @ViewBuilder
    private func shimmerGrid() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(0..<6, id: \.self) { _ in
                ProductCardSkeletonView()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private func emptyState(title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            Spacer(minLength: 60)
            Image(systemName: "heart.slash")
                .font(.system(size: 44))
                .foregroundStyle(DSColors.textSecondary)
                .padding(.bottom, 8)
            Text(title)
                .font(DSTypography.buttonTitle)
                .foregroundStyle(DSColors.textPrimary)
            Text(subtitle)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private func errorView(_ description: String, retry: @escaping () -> Void) -> some View {
        VStack(spacing: 8) {
            Spacer(minLength: 60)
            Text("Не удалось загрузить товары")
                .font(DSTypography.buttonTitle)
                .foregroundStyle(DSColors.textPrimary)
            Text(description)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
            Button("Повторить", action: retry)
                .padding(.top, 8)
            Spacer(minLength: 60)
        }
    }
}
