//
//  DSRating.swift
//  DesignSystem
//
//  Компонент рейтинга в виде звёзд
//

import SwiftUI

/// Рейтинг в виде звёзд.
/// - **Отображение** (`rating:`): показывает целую оценку и половину (например 4.5 = 4 полные + 1 половина).
/// - **Выбор** (`onRatingChange:`): интерактивные звёзды, пользователь выбирает оценку по нажатию.
public struct DSRating: View {

    private let rating: Double
    private let isInteractive: Bool
    private let onRatingChange: (Int) -> Void

    /// Максимальное количество звёзд.
    public let maxRating: Int

    /// Размер одной звезды.
    public var size: CGFloat

    @State private var interactiveValue: Int = 0

    /// Инициализатор для **отображения** рейтинга.
    /// - Parameter rating: оценка (дробная, поддерживается половина).
    public init(
        rating: Double,
        maxRating: Int = 5,
        size: CGFloat = 12
    ) {
        self.rating = rating
        self.maxRating = maxRating
        self.size = size
        self.isInteractive = false
        self.onRatingChange = { _ in }
    }

    /// Инициализатор для **выбора** оценки.
    public init(
        maxRating: Int = 5,
        size: CGFloat = 32,
        onRatingChange: @escaping (Int) -> Void
    ) {
        self.rating = 0
        self.maxRating = maxRating
        self.size = size
        self.isInteractive = true
        self.onRatingChange = onRatingChange
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                star(index: index)
            }
        }
    }

    @ViewBuilder
    private func star(index: Int) -> some View {
        let fullStars = Int(rating.rounded(.down))
        let hasFraction = rating - Double(fullStars) > 0.001
        let isFilled = isInteractive ? index <= interactiveValue : index <= fullStars
        let isHalf = !isInteractive && hasFraction && index == fullStars + 1

        switch (isFilled, isHalf) {
        case (true, _):
            starImage(systemName: "star.fill", index: index)
        case (false, true):
            starImage(systemName: "star.leadinghalf.filled", index: index)
        default:
            starImage(systemName: "star", index: index)
        }
    }

    private func starImage(systemName: String, index: Int) -> some View {
        Image(systemName: systemName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size, height: size)
            .foregroundStyle(DSColors.textPrimary)
            .onTapGesture {
                guard isInteractive else { return }
                interactiveValue = index
                onRatingChange(index)
            }
    }
}

#Preview("Отображение") {
    DSRating(rating: 4.5)
        .padding()
}

#Preview("Выбор") {
    DSRating { rating in
        print(rating)
    }
    .padding()
}