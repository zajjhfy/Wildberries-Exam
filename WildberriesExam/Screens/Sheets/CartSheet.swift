//
//  CartSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct CartSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(CartViewModel.self) private var cartViewModel
    @Environment(AddressesViewModel.self) private var addressesViewModel
    @Environment(OrdersViewModel.self) private var ordersViewModel

    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    private let orderService: any OrderService
    private let cartStore: CartStore

    public init(orderService: any OrderService, cartStore: CartStore) {
        self.orderService = orderService
        self.cartStore = cartStore
    }

    private var snapshot: CartSnapshot? {
        cartViewModel.snapshot
    }

    private var availableItems: [CartItem] {
        snapshot?.items.filter(\.isAvailable) ?? []
    }

    private var unavailableItems: [CartItem] {
        snapshot?.items.filter { !$0.isAvailable } ?? []
    }

    private var currentAddress: DeliveryAddress? {
        if let selectedID = addressesViewModel.selectedAddressID {
            return addressesViewModel.addresses.first(where: { $0.id == selectedID })
        }
        return addressesViewModel.addresses.first
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            if availableItems.isEmpty && unavailableItems.isEmpty {
                emptyCartView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {
                        // Delivery time subtitle
                        Text("\(snapshot?.deliveryTime ?? 15) минут · \(pluralizedItems(snapshot?.totalItems ?? 0))")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(DSColors.textPrimary)

                        // Available items list
                        VStack(spacing: 16) {
                            ForEach(availableItems) { item in
                                cartItemRow(item: item)
                                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                            }
                        }
                        .animation(.easeInOut(duration: 0.25), value: availableItems)

                        // Unavailable items section
                        if !unavailableItems.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Недоступны для заказа")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(DSColors.textPrimary)
                                    .padding(.top, 8)

                                ForEach(unavailableItems) { item in
                                    unavailableItemRow(item: item)
                                }
                            }
                        }

                        // Delivery address & payment section
                        addressAndPaymentSection
                            .padding(.top, 6)

                        if let error = errorMessage {
                            Text(error)
                                .font(DSTypography.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }

                // Bottom Checkout Button (Не трогаем)
                DSCheckoutButton(
                    price: snapshot?.totalPrice ?? 0,
                    count: snapshot?.totalItems ?? 0,
                    isExpanded: true,
                    isLoading: isSubmitting,
                    action: {
                        performCheckout()
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(DSColors.screenBackground)
                .shadow(color: Color.black.opacity(0.06), radius: 6, x: 0, y: -3)
            }
        }
    }

    private var headerView: some View {
        HStack(alignment: .firstTextBaseline, spacing: 6) {
            Text("Корзина")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            Text("\(snapshot?.totalItems ?? 0)")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(Color(red: 205 / 255, green: 205 / 255, blue: 218 / 255))

            Spacer()

            DSCloseButton(action: {
                router.dismissTopSheet()
            })
            .padding(.top, 4)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 8)
    }

    private var emptyCartView: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 60)
            Image(systemName: "cart")
                .font(.system(size: 48))
                .foregroundStyle(DSColors.textSecondary)
            Text("Корзина пуста")
                .font(DSTypography.buttonTitle)
                .foregroundStyle(DSColors.textPrimary)
            Text("Выберите понравившиеся товары в каталоге")
                .font(DSTypography.caption)
                .foregroundStyle(DSColors.textSecondary)
            Spacer(minLength: 60)
        }
        .frame(maxWidth: .infinity)
    }

    private func cartItemRow(item: CartItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            DSAsyncImage(
                urlString: item.imageURL?.absoluteString ?? "",
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                },
                placeholder: {
                    DSImagePlaceholder(cornerRadius: 16)
                        .frame(width: 104, height: 104)
                }
            )
            .frame(width: 104, height: 104)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(item.price) ₽")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)

                (Text(item.name)
                    .foregroundColor(DSColors.textPrimary)
                 + Text(" ")
                 + Text("\(item.weight) г")
                    .foregroundColor(DSColors.textSecondary))
                .font(.system(size: 15, weight: .regular))
                .lineLimit(2)

                Spacer(minLength: 4)

                DSCountButton(
                    count: item.quantity,
                    onDecrement: {
                        Task {
                            await cartViewModel.remove(productID: item.id)
                        }
                    },
                    onIncrement: {
                        Task {
                            await cartViewModel.add(productID: item.id)
                        }
                    }
                )
            }
            .padding(.top, 2)

            Spacer()
        }
        .frame(height: 104)
    }

    private func unavailableItemRow(item: CartItem) -> some View {
        HStack(alignment: .top, spacing: 14) {
            DSAsyncImage(
                urlString: item.imageURL?.absoluteString ?? "",
                content: { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 104, height: 104)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                },
                placeholder: {
                    DSImagePlaceholder(cornerRadius: 16)
                        .frame(width: 104, height: 104)
                }
            )
            .frame(width: 104, height: 104)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(item.price) ₽")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)

                (Text(item.name)
                    .foregroundColor(DSColors.textPrimary)
                 + Text(" ")
                 + Text("\(item.weight) г")
                    .foregroundColor(DSColors.textSecondary))
                .font(.system(size: 15, weight: .regular))
                .lineLimit(1)

                Spacer(minLength: 4)

                Button(action: {
                    Task { await cartViewModel.remove(productID: item.id) }
                }) {
                    Text("Заменить")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(DSColors.textPrimary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 8)
                        .background(DSColors.smoky)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 2)

            Spacer()
        }
        .frame(height: 104)
    }

    private var addressAndPaymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Address row
            Button(action: {
                router.presentSheet(.addresses)
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(currentAddress?.details.addressLine ?? "Выберите адрес доставки")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(DSColors.textPrimary)
                            .lineLimit(1)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(DSColors.textPrimary)
                    }

                    if let details = currentAddress?.details {
                        let detailsStr = [
                            details.floor.map { "\($0) этаж" },
                            details.entrance.map { "\($0) подъезд" },
                            details.intercomCode.map { "код домофона \($0)" }
                        ].compactMap { $0 }.joined(separator: ", ")

                        if !detailsStr.isEmpty {
                            Text(detailsStr)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundStyle(DSColors.textSecondary)
                        }
                    }
                }
            }
            .buttonStyle(.plain)

            // Payment row
            Button(action: {
                // Payment method selection
            }) {
                HStack(spacing: 4) {
                    Text("Оплата картой")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(DSColors.textSecondary)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(DSColors.textSecondary)
                }
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 254 / 255, green: 243 / 255, blue: 252 / 255),
                    Color(red: 251 / 255, green: 242 / 255, blue: 254 / 255)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func pluralizedItems(_ count: Int) -> String {
        let remainderTen = count % 10
        let remainderHundred = count % 100

        if remainderHundred >= 11 && remainderHundred <= 19 {
            return "\(count) товаров"
        }

        switch remainderTen {
        case 1:
            return "\(count) товар"
        case 2, 3, 4:
            return "\(count) товара"
        default:
            return "\(count) товаров"
        }
    }

    private func performCheckout() {
        guard !isSubmitting else { return }

        guard let address = currentAddress else {
            errorMessage = "Пожалуйста, выберите адрес доставки"
            return
        }

        isSubmitting = true
        errorMessage = nil

        Task {
            do {
                let updated = try await cartStore.checkout(
                    orderService: orderService,
                    addressID: address.id,
                    paymentMethod: "card"
                )
                cartViewModel.applyCheckoutResult(updated)
                await ordersViewModel.load()
                isSubmitting = false

                // Show success screen
                router.presentSheet(.orderSuccess)
            } catch {
                isSubmitting = false
                errorMessage = error.localizedDescription
            }
        }
    }
}
