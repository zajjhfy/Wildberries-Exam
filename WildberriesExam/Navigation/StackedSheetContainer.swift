//
//  StackedSheetContainer.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

struct StackedSheetContainer<Content: View>: View {
    @EnvironmentObject private var router: AppRouter

    private let appDependencies: AppDependencies
    private let content: () -> Content

    init(appDependencies: AppDependencies, @ViewBuilder content: @escaping () -> Content) {
        self.appDependencies = appDependencies
        self.content = content
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            content()

            if !router.sheetStack.isEmpty {
                // 40% Black backdrop
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture {
                        router.dismissTopSheet()
                    }
                    .zIndex(50)

                // Stacked sheets (LIFO)
                GeometryReader { geometry in
                    let screenHeight = geometry.size.height
                    ForEach(Array(router.sheetStack.enumerated()), id: \.element.id) { index, sheet in
                        let isTop = index == router.sheetStack.count - 1
                        let sheetHeight = maxHeight(for: sheet, in: screenHeight)

                        SheetCardWrapper(
                            isTop: isTop,
                            height: sheetHeight,
                            onDismiss: {
                                router.dismissTopSheet()
                            }
                        ) {
                            sheetView(for: sheet)
                        }
                        .zIndex(Double(51 + index))
                        .frame(maxHeight: .infinity, alignment: .bottom)
                        .transition(.asymmetric(
                            insertion: .move(edge: .bottom),
                            removal: .move(edge: .bottom)
                        ))
                    }
                }
                .ignoresSafeArea(edges: .bottom)
                .zIndex(51)
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.86), value: router.sheetStack)
    }

    private func maxHeight(for sheet: AppSheet, in screenHeight: CGFloat) -> CGFloat {
        switch sheet {
        case .reviewSuccess, .orderSuccess:
            return 420
        case .addressMap:
            return screenHeight * 0.94
        default:
            return screenHeight * 0.90
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .product(let id):
            ProductDetailSheet(productID: id, service: appDependencies.productService)
        case .reviews(let id):
            ReviewsSheet(productID: id, service: appDependencies.productService)
        case .addReview(let id):
            AddReviewSheet(productID: id, service: appDependencies.productService)
        case .reviewSuccess:
            ReviewSuccessView()
        case .cart:
            CartSheet(orderService: appDependencies.orderService, cartStore: appDependencies.cartStore)
        case .orderSuccess:
            OrderSuccessOverlay()
        case .profile:
            ProfileSheet()
        case .editProfile:
            EditProfileSheet()
        case .orderDetails(let id):
            OrderDetailsSheet(orderID: id)
        case .addresses:
            AddressesSheet()
        case .addressMap(let mode):
            AddressMapSheet(mode: mode)
        case .addressSearch:
            AddressSearchSheet()
        case .addressDetails(let mode):
            AddressDetailsSheet(mode: mode)
        }
    }
}

private struct SheetCardWrapper<Content: View>: View {
    let isTop: Bool
    let height: CGFloat
    let onDismiss: () -> Void
    let content: () -> Content

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        content()
            .frame(maxWidth: .infinity)
            .frame(height: height, alignment: .top)
            .background(DSColors.screenBackground)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 28,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 28,
                    style: .continuous
                )
            )
            .shadow(color: Color.black.opacity(0.18), radius: 14, x: 0, y: -4)
            .offset(y: max(0, dragOffset))
            .simultaneousGesture(
                DragGesture(minimumDistance: 25)
                    .onChanged { value in
                        guard isTop else { return }
                        if value.startLocation.y < 80 && value.translation.height > 0 && abs(value.translation.height) > abs(value.translation.width) {
                            dragOffset = value.translation.height
                        }
                    }
                    .onEnded { value in
                        guard isTop else { return }
                        if value.startLocation.y < 80 && (value.translation.height > 80 || value.predictedEndTranslation.height > 200) {
                            onDismiss()
                        } else {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                            }
                        }
                    }
            )
    }
}
