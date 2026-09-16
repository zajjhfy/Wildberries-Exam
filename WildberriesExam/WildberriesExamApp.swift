//
//  WildberriesExamApp.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 08.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

@main
struct WildberriesExamApp: App {
    @StateObject private var router = AppRouter()
    private let appDependencies: AppDependencies

    @State private var cartViewModel: CartViewModel?
    @State private var favoritesViewModel: FavoritesViewModel?
    @State private var addressesViewModel: AddressesViewModel?
    @State private var ordersViewModel: OrdersViewModel?
    @State private var profileViewModel: ProfileViewModel?
    @State private var discoveryViewModel: CatalogDiscoveryViewModel?

    init() {
        let deps = Self.makeAppDependencies()
        self.appDependencies = deps

        do {
            _cartViewModel = State(initialValue: try deps.makeCartViewModel())
        } catch {
            fatalError("Failed to initialize CartViewModel: \(error)")
        }
        _favoritesViewModel = State(initialValue: deps.makeFavoritesViewModel())
        _addressesViewModel = State(initialValue: deps.makeAddressesViewModel())
        _ordersViewModel = State(initialValue: deps.makeOrdersViewModel())
        _profileViewModel = State(initialValue: deps.makeProfileViewModel())
        _discoveryViewModel = State(initialValue: deps.makeDiscoveryViewModel())
    }

    var body: some Scene {
        WindowGroup {
            if let cartViewModel,
               let favoritesViewModel,
               let addressesViewModel,
               let ordersViewModel,
               let profileViewModel,
               let discoveryViewModel {
                StackedSheetContainer(appDependencies: appDependencies) {
                    NavigationStack(path: $router.path) {
                        MainView(viewModel: CatalogViewModel(service: appDependencies.catalogService))
                            .navigationDestination(for: Route.self) { route in
                                destination(for: route)
                            }
                    }
                }
                .environmentObject(router)
                .environment(cartViewModel)
                .environment(favoritesViewModel)
                .environment(addressesViewModel)
                .environment(ordersViewModel)
                .environment(profileViewModel)
                .environment(discoveryViewModel)
                .task {
                    // Preload and synchronize user data on app launch
                    await cartViewModel.load()
                    await favoritesViewModel.load()
                    await addressesViewModel.load()
                    await ordersViewModel.load()
                    await profileViewModel.load()
                }
            }
        }
    }
}

extension WildberriesExamApp {
    private static func makeAppDependencies() -> AppDependencies {
        do {
            return try AppDependencies()
        } catch {
            fatalError("Failed to initialize AppDependencies: \(error)")
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .category(let id, let title):
            CatalogProductsView(id: id, title: title, service: appDependencies.catalogService)
        }
    }
}
