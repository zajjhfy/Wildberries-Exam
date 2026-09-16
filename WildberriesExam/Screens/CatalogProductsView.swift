//
//  CatalogProductsView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct CatalogProductsView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(FavoritesViewModel.self) private var favoritesViewModel

    @State private var viewModel: CatalogViewModel
    private let id: String
    private let title: String
    private var prefetchThreshold: CGFloat = 200

    public init(id: String, title: String, service: any CatalogService) {
        self.id = id
        self.title = title
        _viewModel = State(initialValue: CatalogViewModel(service: service))
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                if viewModel.state == .loading && viewModel.products.isEmpty {
                    loadingGrid()
                } else if case let .failed(error) = viewModel.state, viewModel.products.isEmpty {
                    errorState(error)
                } else {
                    ScrollView {
                        productsGrid()
                            .padding(.bottom, 80)
                    }
                    .onScrollGeometryChange(for: Bool.self) { geometry in
                        let distanceFromBottom = geometry.contentSize.height - geometry.visibleRect.maxY
                        return distanceFromBottom < prefetchThreshold
                    } action: { wasNearBottom, isNowNearBottom in
                        guard isNowNearBottom, !wasNearBottom else { return }
                        Task { await viewModel.loadNextPage() }
                    }
                }
            }

            FloatingBottomBarView()
        }
        .task(id: id) {
            // Load category products once without redundant refresh
            await viewModel.selectCategory(id)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension CatalogProductsView {
    @ViewBuilder
    private func loadingGrid() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(0..<6, id: \.self) { _ in
                    ProductCardSkeletonView()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
        }
    }

    @ViewBuilder
    private func errorState(_ errorDescription: String) -> some View {
        Spacer()
        VStack(spacing: 8) {
            Text("Ошибка загрузки")
                .font(DSTypography.buttonTitle)
                .foregroundStyle(DSColors.textPrimary)
            Text(errorDescription)
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
                .multilineTextAlignment(.center)
            Button("Повторить") {
                Task { await viewModel.selectCategory(id) }
            }
            .padding(.top, 8)
        }
        .padding()
        Spacer()
    }

    private func productsGrid() -> some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]

        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.products) { product in
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
        .padding(.top, 16)
    }
}
