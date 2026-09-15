import Foundation
import Observation

@MainActor
@Observable
public final class CheckoutViewModel {
    public private(set) var isSubmitting = false
    public private(set) var didPlaceOrder = false
    public private(set) var submissionError: String?
    public private(set) var cartRefreshError: String?
    public private(set) var orderHistoryError: String?

    @ObservationIgnored private let cartStore: CartStore
    @ObservationIgnored private let cartViewModel: CartViewModel
    @ObservationIgnored private let addresses: AddressesViewModel
    @ObservationIgnored private let orders: OrdersViewModel
    @ObservationIgnored private let orderService: any OrderService

    public init(cartStore: CartStore, cartViewModel: CartViewModel,
                addresses: AddressesViewModel, orders: OrdersViewModel,
                orderService: any OrderService) {
        self.cartStore = cartStore
        self.cartViewModel = cartViewModel
        self.addresses = addresses
        self.orders = orders
        self.orderService = orderService
    }

    @discardableResult
    public func placeOrder(paymentMethod: String = "card") async -> Bool {
        guard !isSubmitting, !didPlaceOrder else { return false }
        isSubmitting = true
        defer { isSubmitting = false }
        submissionError = nil
        cartRefreshError = nil
        orderHistoryError = nil
        guard let addressID = addresses.selectedAddressID,
              addresses.addresses.contains(where: { $0.id == addressID }) else {
            submissionError = CartError.missingAddress.localizedDescription
            return false
        }
        do {
            let updated = try await cartStore.checkout(orderService: orderService,
                                                       addressID: addressID, paymentMethod: paymentMethod)
            didPlaceOrder = true
            cartViewModel.applyCheckoutResult(updated)
            if updated == nil {
                cartRefreshError = "Заказ создан. Обнови корзину, чтобы увидеть актуальные данные."
            }
        } catch {
            if !(error is CancellationError) {
                submissionError = "Не удалось подтвердить создание заказа. Проверь историю заказов перед повторной отправкой: \(error.localizedDescription)"
            }
            return false
        }
        await orders.load()
        if case .failed(let message) = orders.state { orderHistoryError = message }
        return true
    }
}
