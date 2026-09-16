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
        let c5 = reviews.filter { $0.rating == 5 }.count
        let c4 = reviews.filter { $0.rating == 4 }.count
        let c3 = reviews.filter { $0.rating == 3 }.count
        let c2 = reviews.filter { $0.rating == 2 }.count
        let c1 = reviews.filter { $0.rating == 1 }.count

        let total = c5 + c4 + c3 + c2 + c1
        let divisor = total > 0 ? Double(total) : 1.0

        return [
            (5, c5, total > 0 ? Double(c5) / divisor : 0.0),
            (4, c4, total > 0 ? Double(c4) / divisor : 0.0),
            (3, c3, total > 0 ? Double(c3) / divisor : 0.0),
            (2, c2, total > 0 ? Double(c2) / divisor : 0.0),
            (1, c1, total > 0 ? Double(c1) / divisor : 0.0)
        ]
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text("Отзывы")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)

                Text("\(displayReviewsCount)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(Color(uiColor: .systemGray3))

                Spacer()

                DSCloseButton(action: {
                    router.dismissTopSheet()
                })
            }
            .padding(.horizontal)
            .padding(.top)

            if viewModel.state == .loading && details == nil {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(height: 300)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        // Rating overview
                        ratingOverview

                        // Write review button
                        DSButton(
                            action: {
                                router.presentSheet(.addReview(productID: productID))
                            },
                            buttonTitle: "Написать отзыв",
                            style: .light
                        )

                        // Reviews list
                        if viewModel.visibleReviews.isEmpty {
                            Text("Пока нет отзывов. Будьте первым!")
                                .font(DSTypography.caption)
                                .foregroundStyle(DSColors.textSecondary)
                                .padding(.top, 16)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(Array(viewModel.visibleReviews.enumerated()), id: \.offset) { _, review in
                                    reviewCard(review: review)
                                }
                            }
                        }
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

    private var ratingOverview: some View {
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
            // Right-aligned star column
            HStack(spacing: 2) {
                ForEach(0..<stars, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(stars >= 4 ? DSColors.textPrimary : Color(uiColor: .systemGray3))
                }
            }
            .frame(width: 52, alignment: .trailing)

            // Thin indicator line
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

            // Count number
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
            let iso = ISO8601DateFormatter()
            return iso.date(from: review.createdAtText)
        }()

        if let date {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ru_RU")
            formatter.dateFormat = "d MMMM"
            return formatter.string(from: date)
        }
        return review.createdAtText
    }
}
