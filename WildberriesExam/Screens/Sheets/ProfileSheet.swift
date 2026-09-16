//
//  ProfileSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct ProfileSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(ProfileViewModel.self) private var profileViewModel
    @Environment(OrdersViewModel.self) private var ordersViewModel

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header(
                onEditProfile: { router.presentSheet(.editProfile) },
                onClose: { router.dismissTopSheet() }
            )

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    if let active = activeOrder {
                        activeOrderSection(active) {
                            router.presentSheet(.orderDetails(orderID: active.id))
                        }
                    }

                    completedOrdersSection()
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 24)
            }
        }
        .task {
            await profileViewModel.load()
            await ordersViewModel.load()
        }
    }
}

extension ProfileSheet {
    private var profile: UserProfile? {
        profileViewModel.profile
    }

    private var userInitial: String {
        if let name = profile?.name, let first = name.first {
            return String(first).uppercased()
        }
        return "А"
    }

    private var activeOrder: CustomerOrder? {
        ordersViewModel.orders.first(where: { $0.status == .active })
    }

    private var completedOrders: [CustomerOrder] {
        ordersViewModel.orders.filter { $0.status == .completed }
    }

    private func formatPhone(_ raw: String) -> String {
        let digits = raw.filter(\.isNumber)
        if digits.count == 11, digits.first == "7" || digits.first == "8" {
            let code = digits.dropFirst().prefix(3)
            let part1 = digits.dropFirst(4).prefix(3)
            let part2 = digits.dropFirst(7).prefix(2)
            let part3 = digits.dropFirst(9).prefix(2)
            return "+7 \(code) \(part1)-\(part2)-\(part3)"
        } else if digits.count == 10 {
            let code = digits.prefix(3)
            let part1 = digits.dropFirst(3).prefix(3)
            let part2 = digits.dropFirst(6).prefix(2)
            let part3 = digits.dropFirst(8).prefix(2)
            return "+7 \(code) \(part1)-\(part2)-\(part3)"
        }
        return raw
    }

    private func header(
        onEditProfile: @escaping () -> Void,
        onClose: @escaping () -> Void
    ) -> some View {
        HStack(alignment: .center) {
            Button(action: onEditProfile) {
                HStack(spacing: 14) {
                    Circle()
                        .fill(Color(red: 0.92, green: 0.91, blue: 0.96))
                        .frame(width: 54, height: 54)
                        .overlay(
                            Text(userInitial)
                                .font(.system(size: 24, weight: .regular))
                                .foregroundStyle(DSColors.textPrimary)
                        )

                    VStack(alignment: .leading, spacing: 4) {
                        Text(profile?.name ?? "Анастасия")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(DSColors.textPrimary)

                        HStack(spacing: 4) {
                            Text(formatPhone(profile?.phone ?? "+7 908 305-80-34"))
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(DSColors.textSecondary)

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            DSCloseButton(action: onClose)
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 12)
    }

    private func activeOrderSection(_ active: CustomerOrder, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            DSActiveOrderView(active)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func completedOrdersSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("История заказов")
                .font(DSTypography.buttonTitle)
                .foregroundStyle(DSColors.textPrimary)
                .padding(.top, 4)

            if completedOrders.isEmpty {
                Text("У вас пока нет завершенных заказов")
                    .font(DSTypography.caption)
                    .foregroundStyle(DSColors.textSecondary)
                    .padding(.vertical, 8)
            } else {
                ForEach(completedOrders) { order in
                    Button(action: {
                        router.presentSheet(.orderDetails(orderID: order.id))
                    }) {
                        DSCompletedOrderView(order)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
