//
//  AddressesSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct AddressesSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(AddressesViewModel.self) private var addressesViewModel

    public init() {}

    public var body: some View {
        VStack {
            header {
                router.dismissTopSheet()
            }

            ScrollView {
                VStack(spacing: 12) {
                    addressList()

                    addNewAddressButton {
                        router.presentSheet(.addressMap(mode: .create))
                    }
                }
                .padding(.vertical, 8)
            }

            confirmButton {
                router.dismissTopSheet()
            }
        }
        .task {
            if addressesViewModel.state != .loaded {
                await addressesViewModel.load()
            }
        }
    }
}

extension AddressesSheet {
    private func header(onClose: @escaping () -> Void) -> some View {
        HStack {
            Text("Мои адреса")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)

            Spacer()

            DSCloseButton(action: onClose)
        }
        .padding(.horizontal, 16)
        .padding(.top, 14)
        .padding(.bottom, 8)
    }

    @ViewBuilder
    private func addressList() -> some View {
        ForEach(addressesViewModel.addresses) { address in
            let isSelected = address.id == addressesViewModel.selectedAddressID
                || (addressesViewModel.selectedAddressID == nil && address.id == addressesViewModel.addresses.first?.id)

            DSAddressCell(
                address: address,
                isSelected: isSelected,
                onTapEdit: {
                    router.presentSheet(.addressDetails(mode: .edit(
                        addressID: address.id,
                        addressLine: address.details.addressLine,
                        floor: address.details.floor,
                        entrance: address.details.entrance,
                        intercomCode: address.details.intercomCode,
                        comment: address.details.comment
                    )))
                }
            )
            .contentShape(Rectangle())
            .onTapGesture {
                addressesViewModel.selectedAddressID = address.id
            }
        }
    }

    private func addNewAddressButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)

                Text("Новый адрес")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func confirmButton(action: @escaping () -> Void) -> some View {
        DSButton(
            action: action,
            buttonTitle: "Привезти сюда",
            style: .accent
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
    }
}
