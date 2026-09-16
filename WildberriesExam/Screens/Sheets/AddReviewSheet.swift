//
//  AddReviewSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct AddReviewSheet: View {
    @EnvironmentObject private var router: AppRouter

    @State private var viewModel: ProductViewModel
    @State private var rating: Int = 0
    @State private var commentText: String = ""
    @State private var isSubmitting: Bool = false

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

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let product = product {
                        productInfoRow(product: product)
                    }

                    ratingSection()
                    commentSection()
                    mediaUploadSection()
                    agreementText()

                    if let error = viewModel.submissionError {
                        errorText(error)
                    }

                    submitButton(
                        isLoading: isSubmitting,
                        isDisabled: rating == 0 || isSubmitting
                    ) {
                        submitReview()
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
            .scrollDismissesKeyboard(.immediately)
        }
        .task {
            await viewModel.load()
        }
    }
}

extension AddReviewSheet {
    private var details: ProductDetails? {
        viewModel.details
    }

    private var product: CatalogProduct? {
        details?.product
    }

    private func header(onClose: @escaping () -> Void) -> some View {
        HStack {
            Text("Отзыв о товаре")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            Spacer()

            DSCloseButton(action: onClose)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    @ViewBuilder
    private func productInfoRow(product: CatalogProduct) -> some View {
        HStack(alignment: .top, spacing: 14) {
            DSAsyncImage(
                urlString: product.imageURL?.absoluteString ?? "",
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                },
                placeholder: {
                    DSImagePlaceholder(cornerRadius: 12)
                        .frame(width: 80, height: 80)
                }
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(product.name)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(DSColors.textPrimary)

                    Text("\(Int(product.weight)) г")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)
                }

                if let desc = details?.description, !desc.isEmpty {
                    Text(desc)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundStyle(DSColors.textPrimary)
                        .lineLimit(3)
                        .lineSpacing(2)
                }
            }
        }
    }

    private func ratingSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Оценка")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button(action: {
                        rating = star
                    }) {
                        Image(systemName: star <= rating ? "star.fill" : "star")
                            .font(.system(size: 36, weight: .light))
                            .foregroundStyle(
                                star <= rating ? DSColors.accent : Color(uiColor: .systemGray4)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func commentSection() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Комментарий")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            ZStack(alignment: .topLeading) {
                if commentText.isEmpty {
                    Text("Впечатления, пожелания, проблемы с удобными пуфиками, большими зеркалами и плотной шторкой.")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 14)
                }

                TextEditor(text: $commentText)
                    .font(.system(size: 14, weight: .regular))
                    .scrollContentBackground(.hidden)
                    .padding(8)
            }
            .frame(height: 100)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color(uiColor: .systemGray5), lineWidth: 1)
            )
        }
    }

    private func mediaUploadSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(DSColors.smoky)
                        .frame(width: 54, height: 54)

                    Image(systemName: "camera")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color(red: 0.89, green: 0.07, blue: 0.75))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("5 файлов JPG, PNG, BMP, GIF.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)

                    Text("до 10 МБ каждый")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)
                }

                Spacer()
            }

            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(DSColors.smoky)
                        .frame(width: 54, height: 54)

                    Image(systemName: "video")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color(red: 0.89, green: 0.07, blue: 0.75))
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text("Видео в формате MOV, MP4.")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)

                    Text("до 300 МБ")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)
                }

                Spacer()
            }
        }
    }

    private func agreementText() -> some View {
        Text("Соглашаюсь с правилами публикации")
            .font(.system(size: 14, weight: .regular))
            .foregroundStyle(DSColors.textPrimary)
            .padding(.top, 4)
    }

    private func errorText(_ error: String) -> some View {
        Text(error)
            .font(DSTypography.caption)
            .foregroundStyle(.red)
    }

    private func submitButton(isLoading: Bool, isDisabled: Bool, action: @escaping () -> Void) -> some View {
        DSButton(
            action: action,
            buttonTitle: "Оставить отзыв",
            style: .accent,
            isLoading: isLoading,
            disabled: isDisabled
        )
        .padding(.top, 4)
    }

    private func submitReview() {
        guard !isSubmitting else { return }
        isSubmitting = true

        Task {
            let draft = ReviewDraft(
                rating: rating,
                content: commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Отличный товар!" : commentText,
                imageURLs: []
            )

            let success = await viewModel.submit(draft)
            isSubmitting = false

            if success {
                router.replaceTopSheet(with: .reviewSuccess)
            }
        }
    }
}
