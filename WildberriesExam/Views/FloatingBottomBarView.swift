//
//  FloatingBottomBarView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

public struct FloatingBottomBarView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(OrdersViewModel.self) private var ordersViewModel

    @State private var isFocused: Bool = false

    public init() {}

    private var activeOrder: CustomerOrder? {
        ordersViewModel.orders.first(where: { $0.status == .active })
    }

    private var cartItemsCount: Int {
        cartViewModel.snapshot?.totalItems ?? 0
    }

    private var cartTotalPrice: Int {
        cartViewModel.snapshot?.totalPrice ?? 0
    }

    public var body: some View {
        HStack(spacing: 8) {
            if router.isSearchPresented {
                DSSearchBar(
                    searchText: $router.searchQuery,
                    isFocused: $isFocused,
                    action: {
                        isFocused = false
                    }
                )
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity),
                    removal: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity)
                ))

                closeSearchButton
                    .transition(.opacity)
            } else {
                DSSearchButton {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                        router.isSearchPresented = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                        isFocused = true
                    }
                }
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity),
                    removal: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity)
                ))

                if let order = activeOrder {
                    activeOrderStatusButton(order: order)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                } else if cartItemsCount > 0 {
                    DSCheckoutButton(
                        price: cartTotalPrice,
                        count: cartItemsCount,
                        isExpanded: false,
                        action: {
                            router.presentSheet(.cart)
                        }
                    )
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.isSearchPresented)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: cartItemsCount)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: activeOrder != nil)
    }

    private var closeSearchButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                isFocused = false
                router.isSearchPresented = false
            }
        }) {
            RoundedRectangle(cornerRadius: 12)
                .overlay {
                    Image(systemName: "xmark")
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .font(DSTypography.searchButtonTitle)
                        .foregroundStyle(DSColors.textPrimary)
                }
                .frame(width: 55, height: 55)
                .foregroundStyle(DSColors.searchBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DSColors.textSecondary.opacity(0.3), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
    }

    private func activeOrderStatusButton(order: CustomerOrder) -> some View {
        Button(action: {
            router.presentSheet(.orderDetails(orderID: order.id))
        }) {
            HStack(spacing: 8) {
                Text("🚀 Доставим через 12 минут")
                    .font(DSTypography.actionTitle)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .frame(height: 55)
            .background(DSColors.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
