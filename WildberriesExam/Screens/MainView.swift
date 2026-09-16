//
//  MainView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct MainView: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(AddressesViewModel.self) private var addressesViewModel
    @Environment(ProfileViewModel.self) private var profileViewModel

    @State var viewModel: CatalogViewModel

    public init(viewModel: CatalogViewModel) {
        self._viewModel = State(initialValue: viewModel)
    }

    private var currentAddressText: String {
        if let selectedID = addressesViewModel.selectedAddressID,
           let address = addressesViewModel.addresses.first(where: { $0.id == selectedID }) {
            return address.details.addressLine
        }
        return addressesViewModel.addresses.first?.details.addressLine ?? ""
    }

    private var userInitial: String {
        if let name = profileViewModel.profile?.name, let first = name.first {
            return String(first).uppercased()
        }
        return "А"
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Top sticky header
                headerView
                    .padding(.horizontal, 16)
                    .padding(.top, 4)

                // Main content: either search view or catalog view
                ZStack {
                    CatalogView(viewModel: viewModel)
                        .opacity(router.isSearchPresented ? 0 : 1)

                    if router.isSearchPresented {
                        SearchView()
                            .transition(.opacity)
                    }
                }
            }

            // Floating bottom bar
            FloatingBottomBarView()
        }
    }

    private var headerView: some View {
        DSAddressView(
            addressText: currentAddressText,
            userInitial: userInitial,
            isCart: false,
            onTapProfile: {
                router.presentSheet(.profile)
            }
        )
        .onTapGesture {
            router.presentSheet(.addresses)
        }
    }
}
