//
//  ReviewsSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct ReviewsSheet: View {
    @EnvironmentObject private var router: AppRouter
    @State private var viewModel: ProductViewModel

    private let productID: String

    public init(productID: String, service: any ProductService) {
        self.productID = productID
        _viewModel = State(initialValue: ProductViewModel(productID: productID, service: service))
    }

    public var body: some View {
        VStack(spacing: 0) {
            header {
                router.dismissTopSheet()
            }

            if viewModel.state == .loading && details == nil {
                loadingView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ratingOverview()

                        writeReviewButton {
                            router.presentSheet(.addReview(productID: productID))
                        }

                        reviewsList()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .task {
            await viewModel.load()
        }
    }
}

extension ReviewsSheet {
    private static let isoFormatter = ISO8601DateFormatter()
    private static let displayDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM"
        return formatter
    }()

    private var details: ProductDetails? {
        viewModel.details
    }

    private var displayReviewsCount: Int {
        if let count = details?.reviews.count, count > 0 {
            return count
        }
        return details?.product.reviewCount ?? 0
    }

    private var averageRating: Double {
        if let r = details?.product.rating, r > 0 {
            return r
        }
        guard let reviews = details?.reviews, !reviews.isEmpty else {
            return 4.9
        }
        let total = reviews.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(reviews.count)
    }

    private var starDistribution: [(stars: Int, count: Int, fraction: Double)] {
        let reviews = details?.reviews ?? []
        var counts = [1: 0, 2: 0, 3: 0, 4: 0, 5: 0]
        for review in reviews {
            counts[review.rating, default: 0] += 1
        }

        let total = reviews.count
        let divisor = total > 0 ? Double(total) : 1.0

        return (1...5).reversed().map { star in
            let count = counts[star, default: 0]
            let fraction = total > 0 ? Double(count) / divisor : 0.0
            return (star, count, fraction)
        }
    }

    private func header(onClose: @escaping () -> Void) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Text("Отзывы")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            Text("\(displayReviewsCount)")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(uiColor: .systemGray3))

            Spacer()

            DSCloseButton(action: onClose)
        }
        .padding(.horizontal)
        .padding(.top)
    }

    private func loadingView() -> some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }
        .frame(height: 300)
    }

    private func writeReviewButton(action: @escaping () -> Void) -> some View {
        DSButton(
            action: action,
            buttonTitle: "Написать отзыв",
            style: .light
        )
    }

    @ViewBuilder
    private func reviewsList() -> some View {
        if viewModel.visibleReviews.isEmpty {
            emptyReviewsView()
        } else {
            VStack(spacing: 12) {
                ForEach(Array(viewModel.visibleReviews.enumerated()), id: \.offset) { _, review in
                    reviewCard(review: review)
                }
            }
        }
    }

    private func emptyReviewsView() -> some View {
        Text("Пока нет отзывов. Будьте первым!")
            .font(DSTypography.caption)
            .foregroundStyle(DSColors.textSecondary)
            .padding(.top, 16)
    }

    private func ratingOverview() -> some View {
        HStack(spacing: 24) {
            Text(String(format: "%.1f", averageRating))
                .font(.system(size: 112, weight: .light))
                .foregroundStyle(DSColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            VStack(spacing: 3.5) {
                ForEach(starDistribution, id: \.stars) { item in
                    distributionRow(stars: item.stars, count: item.count, fraction: item.fraction)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    private func distributionRow(stars: Int, count: Int, fraction: Double) -> some View {
        HStack(spacing: 8) {
            HStack(spacing: 2) {
                ForEach(0..<stars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(count > 0 ? DSColors.textPrimary : Color(uiColor: .systemGray3))
                }
            }
            .frame(width: 52, alignment: .trailing)

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(uiColor: .systemGray5))
                        .frame(height: 1.5)

                    if fraction > 0 {
                        Capsule()
                            .fill(DSColors.textPrimary)
                            .frame(width: max(2, geo.size.width * CGFloat(fraction)), height: 1.5)
                    }
                }
                .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 12)

            Text("\(count)")
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(DSColors.textPrimary)
                .frame(width: 24, alignment: .trailing)
        }
        .frame(height: 14)
    }

    private func reviewCard(review: ProductReview) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 3) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(star <= review.rating ? DSColors.textPrimary : Color(uiColor: .systemGray3))
                }

                Text("\(review.author), \(formatReviewDate(review))")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(DSColors.textPrimary)
                    .padding(.leading, 6)

                Spacer()
            }

            Text(review.content)
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(DSColors.textPrimary)
                .lineSpacing(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(DSColors.smoky)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func formatReviewDate(_ review: ProductReview) -> String {
        let date: Date? = {
            if let d = review.createdAt { return d }
            return Self.isoFormatter.date(from: review.createdAtText)
        }()

        if let date {
            return Self.displayDateFormatter.string(from: date)
        }
        return review.createdAtText
    }
}
