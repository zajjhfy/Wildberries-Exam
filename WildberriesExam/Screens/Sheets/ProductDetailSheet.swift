//
//  ProductDetailSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct ProductDetailSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(FavoritesViewModel.self) private var favoritesViewModel

    @State private var viewModel: ProductViewModel
    @State private var isCompositionExpanded: Bool = false

    private let productID: String

    public init(productID: String, service: any ProductService) {
        self.productID = productID
        _viewModel = State(initialValue: ProductViewModel(productID: productID, service: service))
    }

    private var details: ProductDetails? {
        viewModel.details
    }

    private var product: CatalogProduct? {
        details?.product
    }

    private var quantity: Int {
        cartViewModel.quantity(for: productID)
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Sheet Header with Close Button
            if viewModel.state == .loading && details == nil {
                loadingView
            } else if let product = product {
                ZStack(alignment: .bottom) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // Product Image Card
                            productImageCard(product: product)
                                .overlay(alignment: .topTrailing) {
                                    DSCloseButton { router.dismissTopSheet() }
                                        .padding()
                                }

                            // Price & Favorite Row
                            priceAndFavoriteRow(product: product)

                            // Title & Weight Row
                            titleAndWeightRow(product: product)

                            // Rating & Reviews Row
                            ratingAndReviewsRow(product: product)

                            // Description
                            if let description = details?.description, !description.isEmpty {
                                Text(description)
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(DSColors.textPrimary)
                                    .lineSpacing(4)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 10)
                            }

                            // Composition Accordion
                            compositionAccordion
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 110) // Keep scrollable above bottom button
                        }
                    }

                    // Pinned Bottom Action Bar
                    bottomActionBar(product: product)
                }
            } else {
                errorView
            }
        }
        .task {
            await viewModel.load()
        }
    }

    @ViewBuilder
    private func productImageCard(product: CatalogProduct) -> some View {
        DSAsyncImage(
            urlString: product.imageURL?.absoluteString ?? "",
            content: { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            },
            placeholder: {
                DSImagePlaceholder(cornerRadius: 24)
                    .frame(height: 350)
            }
        )
        .frame(maxWidth: .infinity)
        .frame(height: 350)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    @ViewBuilder
    private func priceAndFavoriteRow(product: CatalogProduct) -> some View {
        HStack(alignment: .center) {
            Text("\(product.price) ₽")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            Spacer()

            Button(action: {
                Task { await favoritesViewModel.toggle(product) }
            }) {
                let isFav = favoritesViewModel.isFavorite(product)
                Image(systemName: "heart.fill")
                    .font(.system(size: 26))
                    .foregroundStyle(isFav ? Color(red: 0.89, green: 0.07, blue: 0.75) : Color.black.opacity(0.18))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
    }

    @ViewBuilder
    private func titleAndWeightRow(product: CatalogProduct) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text(product.name)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            Text("\(Int(product.weight))г")
                .font(.system(size: 24, weight: .medium))
                .foregroundStyle(DSColors.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
    }

    @ViewBuilder
    private func ratingAndReviewsRow(product: CatalogProduct) -> some View {
        Button(action: {
            router.presentSheet(.reviews(productID: productID))
        }) {
            HStack(spacing: 6) {
                Text(product.rating.dsRatingString)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(DSColors.textPrimary)

                DSRating(rating: product.rating, size: 13)

                Image(systemName: "bubble.left")
                    .font(.system(size: 13))
                    .foregroundStyle(DSColors.textPrimary)
                    .padding(.leading, 6)

                Text("\(product.reviewCount) отзывов")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(DSColors.textSecondary)

                Spacer()
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 16)
        .padding(.top, 6)
    }

    private var compositionAccordion: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isCompositionExpanded.toggle()
                }
            }) {
                HStack {
                    Text("Состав")
                        .font(DSTypography.buttonTitle)
                        .foregroundStyle(DSColors.textPrimary)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(DSColors.textSecondary)
                        .rotationEffect(.degrees(isCompositionExpanded ? 180 : 0))
                }
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if isCompositionExpanded {
                Text("Мука пшеничная хлебопекарная высшего сорта, вода питьевая, масло подсолнечное рафинированное, сахар, соль, дрожжи хлебопекарные прессованные, натуральные специи.")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(DSColors.smoky)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    @ViewBuilder
    private func bottomActionBar(product: CatalogProduct) -> some View {
        HStack(spacing: 12) {
            if quantity > 0 {
                stepperControl(product: product)

                DSButton(
                    action: {
                        router.presentSheet(.cart)
                    },
                    buttonTitle: "В корзине",
                    style: .accent
                )
                .frame(maxWidth: .infinity)
            } else {
                DSButton(
                    action: {
                        Task { await cartViewModel.add(productID: product.id) }
                    },
                    buttonTitle: "В корзину",
                    style: .accent
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 28)
        .background(
            LinearGradient(
                stops: [
                    .init(color: DSColors.screenBackground.opacity(0.0), location: 0.0),
                    .init(color: DSColors.screenBackground.opacity(0.95), location: 0.25),
                    .init(color: DSColors.screenBackground, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: quantity > 0)
    }

    @ViewBuilder
    private func stepperControl(product: CatalogProduct) -> some View {
        HStack(spacing: 0) {
            Button(action: {
                Task { await cartViewModel.remove(productID: product.id) }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text("\(quantity)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(DSColors.textPrimary)
                .frame(minWidth: 28)

            Button(action: {
                Task { await cartViewModel.add(productID: product.id) }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 52)
        .background(DSColors.smoky)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(height: 350)
    }

    private var errorView: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Не удалось загрузить товар")
                .font(DSTypography.buttonTitle)
                .foregroundStyle(DSColors.textPrimary)
            Button("Повторить") {
                Task { await viewModel.load() }
            }
            Spacer()
        }
        .frame(height: 300)
    }
}
