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

    public var body: some View {
        HStack(spacing: 8) {
            if router.isSearchPresented {
                searchBar()
            } else {
                searchButton {
                    expandSearch()
                }

                if let order = activeOrder {
                    activeOrderStatusButton(order: order) {
                        router.presentSheet(.orderDetails(orderID: order.id))
                    }
                } else if cartItemsCount > 0 {
                    checkoutButton(price: cartTotalPrice, count: cartItemsCount) {
                        router.presentSheet(.cart)
                    }
                } else {
                    Spacer(minLength: 0)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: router.isSearchPresented)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: cartItemsCount)
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: activeOrder != nil)
    }
}

extension FloatingBottomBarView {
    private var activeOrder: CustomerOrder? {
        ordersViewModel.orders.first(where: { $0.status == .active })
    }

    private var cartItemsCount: Int {
        cartViewModel.snapshot?.totalItems ?? 0
    }

    private var cartTotalPrice: Int {
        cartViewModel.snapshot?.orderPrice ?? 0
    }

    private func searchBar() -> some View {
        DSSearchBar(
            searchText: $router.searchQuery,
            isFocused: $isFocused,
            action: {
                isFocused = false
            }
        )
        .transition(.asymmetric(
            insertion: .scale(scale: 0.95, anchor: .leading).combined(with: .opacity),
            removal: .scale(scale: 0.95, anchor: .leading).combined(with: .opacity)
        ))
    }

    private func searchButton(action: @escaping () -> Void) -> some View {
        DSSearchButton(action: action)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity),
                removal: .scale(scale: 0.9, anchor: .leading).combined(with: .opacity)
            ))
    }

    private func expandSearch() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            router.isSearchPresented = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isFocused = true
        }
    }

    private func activeOrderStatusButton(order: CustomerOrder, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("🚀 Доставим через 12 минут")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
            .padding(.horizontal, 16)
            .frame(height: 50)
            .frame(maxWidth: .infinity)
            .background(DSColors.accentGradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }

    private func checkoutButton(price: Int, count: Int, action: @escaping () -> Void) -> some View {
        DSCheckoutButton(
            price: price,
            count: count,
            isExpanded: true,
            action: action
        )
        .transition(.move(edge: .trailing).combined(with: .opacity))
    }
}
