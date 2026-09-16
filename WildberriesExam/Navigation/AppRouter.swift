//
//  AppRouter.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import Combine
import BusinessLogic

public enum Route: Hashable, Sendable {
    case category(id: String, title: String)
}

public enum AddressMapMode: Hashable, Sendable {
    case create
    case pickLocation(initialCenter: [Double]? = nil)

    public var id: String {
        switch self {
        case .create:
            return "create"
        case .pickLocation(let coords):
            let c = coords?.map { "\($0)" }.joined(separator: "_") ?? "default"
            return "pick_\(c)"
        }
    }
}

public struct SelectedMapLocation: Equatable, Sendable {
    public let addressLine: String
    public let coordinates: [Double]

    public init(addressLine: String, coordinates: [Double]) {
        self.addressLine = addressLine
        self.coordinates = coordinates
    }
}

public enum AddressDetailsMode: Hashable, Sendable {
    case createFromMap(addressLine: String, coordinates: [Double])
    case createFromSearch(addressLine: String)
    case edit(addressID: String, addressLine: String, floor: String?, entrance: String?, intercomCode: String?, comment: String?)

    public var id: String {
        switch self {
        case .createFromMap(let line, _): return "create_map_\(line)"
        case .createFromSearch(let line): return "create_search_\(line)"
        case .edit(let id, _, _, _, _, _): return "edit_\(id)"
        }
    }
}

public enum AppSheet: Identifiable, Hashable, Sendable {
    case product(id: String)
    case reviews(productID: String)
    case addReview(productID: String)
    case reviewSuccess
    case cart
    case orderSuccess
    case profile
    case editProfile
    case orderDetails(orderID: String)
    case addresses
    case addressMap(mode: AddressMapMode)
    case addressSearch
    case addressDetails(mode: AddressDetailsMode)

    public var id: String {
        switch self {
        case .product(let id): return "product_\(id)"
        case .reviews(let id): return "reviews_\(id)"
        case .addReview(let id): return "add_review_\(id)"
        case .reviewSuccess: return "review_success"
        case .cart: return "cart"
        case .orderSuccess: return "order_success"
        case .profile: return "profile"
        case .editProfile: return "edit_profile"
        case .orderDetails(let id): return "order_details_\(id)"
        case .addresses: return "addresses"
        case .addressMap(let mode): return "address_map_\(mode.id)"
        case .addressSearch: return "address_search"
        case .addressDetails(let mode): return "address_details_\(mode.id)"
        }
    }

    public var isSuccess: Bool {
        switch self {
        case .reviewSuccess, .orderSuccess:
            return true
        default:
            return false
        }
    }
}

@MainActor
public final class AppRouter: ObservableObject {
    @Published public var path = NavigationPath()
    @Published public var sheetStack: [AppSheet] = []
    @Published public var searchQuery: String = ""
    @Published public var isSearchPresented: Bool = false
    @Published public var selectedMapLocation: SelectedMapLocation?

    public init() {}

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        path.pop()
    }

    public func popToRoot() {
        path.popToRoot()
    }

    public func popTo(_ target: Int) {
        path.popTo(target)
    }

    public func presentSheet(_ sheet: AppSheet) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            sheetStack.append(sheet)
        }
    }

    public func dismissTopSheet() {
        guard !sheetStack.isEmpty else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            _ = sheetStack.removeLast()
        }
    }

    public func dismissAllSheets() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            sheetStack.removeAll()
        }
    }

    public func popToSheet(_ sheet: AppSheet) {
        guard let index = sheetStack.firstIndex(of: sheet) else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            sheetStack = Array(sheetStack.prefix(through: index))
        }
    }

    public func replaceTopSheet(with sheet: AppSheet) {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
            if !sheetStack.isEmpty {
                _ = sheetStack.removeLast()
            }
            sheetStack.append(sheet)
        }
    }
}

extension NavigationPath {
    mutating func pop() {
        guard !isEmpty else { return }
        removeLast()
    }

    mutating func popTo(_ target: Int) {
        guard target <= count else { return }
        removeLast(count - target)
    }

    mutating func popToRoot() {
        removeLast(count)
    }
}
