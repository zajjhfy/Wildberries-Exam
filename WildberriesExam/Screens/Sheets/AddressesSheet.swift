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
            HStack {
                Text("Мои адреса")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)

                Spacer()

                DSCloseButton(action: {
                    router.dismissTopSheet()
                })
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 8)

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(addressesViewModel.addresses) { address in
                        let isSelected = address.id == addressesViewModel.selectedAddressID
                            || (addressesViewModel.selectedAddressID == nil && address.id == addressesViewModel.addresses.first?.id)

                        DSAddressCell(
                            addressLine: address.details.addressLine,
                            floor: address.details.floor,
                            entrance: address.details.entrance,
                            intercomCode: address.details.intercomCode,
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

                    // Add new address button
                    Button(action: {
                        router.presentSheet(.addressMap(mode: .create))
                    }) {
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
                .padding(.vertical, 8)
            }

            // Bottom action button
            DSButton(
                action: {
                    router.dismissTopSheet()
                },
                buttonTitle: "Привезти сюда",
                style: .accent
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
        .task {
            if addressesViewModel.state != .loaded {
                await addressesViewModel.load()
            }
        }
    }
}
