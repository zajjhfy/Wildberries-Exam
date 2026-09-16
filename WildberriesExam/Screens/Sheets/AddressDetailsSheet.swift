//
//  AddressDetailsSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

public struct AddressDetailsSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(AddressesViewModel.self) private var addressesViewModel

    private let mode: AddressDetailsMode

    @State private var addressLine: String = ""
    @State private var apartment: String = ""
    @State private var entrance: String = ""
    @State private var floor: String = ""
    @State private var intercomCode: String = ""
    @State private var comment: String = ""
    @State private var coordinates: AddressCoordinates = AddressCoordinates(longitude: 37.6622, latitude: 55.7667)!
    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    public init(mode: AddressDetailsMode) {
        self.mode = mode
    }

    private var isEditMode: Bool {
        if case .edit = mode { return true }
        return false
    }

    public var body: some View {
        VStack(spacing: 0) {
            if isEditMode {
                // Top Action Bar in Edit Mode
                HStack {
                    Button(action: {
                        router.dismissTopSheet()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(DSColors.textSecondary)
                            .frame(width: 44, height: 44)
                            .background(DSColors.screenBackground)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.12), radius: 5, x: 0, y: 3)
                            .shadow(color: Color.black.opacity(0.04), radius: 1, x: 0, y: 0)
                    }
                    .buttonStyle(.plain)

                    Spacer()

                    DSSelectMapAddressButton {
                        router.presentSheet(.addressMap(mode: .pickLocation(initialCenter: [coordinates.longitude, coordinates.latitude])))
                    }

                    Spacer()

                    if case let .edit(addressID, _, _, _, _, _) = mode {
                        DSDeleteAddressButton {
                            deleteAddress(id: addressID)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 14)
                .padding(.bottom, 6)
            }

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    // Address Title
                    Text(addressLine)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(DSColors.textPrimary)
                        .lineLimit(2)
                        .padding(.top, isEditMode ? 6 : 24)
                        .padding(.bottom, 6)

                    // 5 Form Fields in single column matching Figma design
                    ManualAddressField(title: "Квартира/офис", placeholder: "Квартира/офис", text: $apartment)
                    ManualAddressField(title: "Подъезд", placeholder: "Подъезд", text: $entrance)
                    ManualAddressField(title: "Этаж", placeholder: "Этаж", text: $floor)
                    ManualAddressField(title: "Код домофона", placeholder: "Код домофона", text: $intercomCode)
                    ManualAddressField(title: "Комментарий", placeholder: "Комментарий", text: $comment)

                    if let error = errorMessage {
                        Text(error)
                            .font(DSTypography.caption)
                            .foregroundStyle(.red)
                            .padding(.top, 4)
                    }

                    // Save Button
                    DSButton(
                        action: {
                            saveAddress()
                        },
                        buttonTitle: "Сохранить",
                        style: .accent,
                        isLoading: isSaving
                    )
                    .padding(.top, 14)
                    .padding(.bottom, 32)
                }
                .padding(.horizontal, 16)
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onAppear {
            setupInitialData()
        }
        .onChange(of: router.selectedMapLocation) { _, newLocation in
            if let newLocation {
                self.addressLine = newLocation.addressLine
                if newLocation.coordinates.count >= 2,
                   let coords = AddressCoordinates(longitude: newLocation.coordinates[0], latitude: newLocation.coordinates[1]) {
                    self.coordinates = coords
                }
                router.selectedMapLocation = nil
            }
        }
    }

    private func setupInitialData() {
        switch mode {
        case .createFromMap(let line, let coords):
            addressLine = line
            if coords.count >= 2, let c = AddressCoordinates(longitude: coords[0], latitude: coords[1]) {
                coordinates = c
            }
        case .createFromSearch(let line):
            addressLine = line
        case .edit(_, let line, let f, let e, let ic, let c):
            var cleanLine = line
            if let range = line.range(of: ", кв. ", options: .caseInsensitive) {
                apartment = String(line[range.upperBound...])
                cleanLine = String(line[..<range.lowerBound])
            } else if let range = line.range(of: ", офис ", options: .caseInsensitive) {
                apartment = String(line[range.upperBound...])
                cleanLine = String(line[..<range.lowerBound])
            }
            addressLine = cleanLine
            floor = f ?? ""
            entrance = e ?? ""
            intercomCode = ic ?? ""
            comment = c ?? ""
        }
    }

    private func saveAddress() {
        guard !isSaving else { return }
        isSaving = true
        errorMessage = nil

        var finalAddressLine = addressLine.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApartment = apartment.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedApartment.isEmpty && !finalAddressLine.lowercased().contains("кв") {
            if trimmedApartment.lowercased().contains("офис") || trimmedApartment.lowercased().contains("кв") {
                finalAddressLine += ", \(trimmedApartment)"
            } else {
                finalAddressLine += ", кв. \(trimmedApartment)"
            }
        }

        let trimmedFloor = floor.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEntrance = entrance.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedIntercom = intercomCode.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)

        let details = AddressDetails(
            addressLine: finalAddressLine,
            coordinates: coordinates,
            floor: trimmedFloor.isEmpty ? nil : trimmedFloor,
            entrance: trimmedEntrance.isEmpty ? nil : trimmedEntrance,
            intercomCode: trimmedIntercom.isEmpty ? nil : trimmedIntercom,
            comment: trimmedComment.isEmpty ? nil : trimmedComment
        )

        Task {
            switch mode {
            case .createFromMap, .createFromSearch:
                await addressesViewModel.create(details)
            case .edit(let addressID, _, _, _, _, _):
                await addressesViewModel.update(id: addressID, details: details)
            }

            isSaving = false
            if addressesViewModel.actionError == nil {
                if let last = addressesViewModel.addresses.last {
                    addressesViewModel.selectedAddressID = last.id
                }
                if router.sheetStack.contains(.addresses) {
                    router.popToSheet(.addresses)
                } else {
                    router.dismissTopSheet()
                }
            } else {
                errorMessage = addressesViewModel.actionError
            }
        }
    }

    private func deleteAddress(id: String) {
        Task {
            await addressesViewModel.delete(id: id)
            if router.sheetStack.contains(.addresses) {
                router.popToSheet(.addresses)
            } else {
                router.dismissTopSheet()
            }
        }
    }
}

private struct ManualAddressField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color(red: 142 / 255, green: 142 / 255, blue: 147 / 255))

            TextField(
                "",
                text: $text,
                prompt: Text(placeholder)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(red: 188 / 255, green: 188 / 255, blue: 194 / 255))
            )
            .font(.system(size: 16, weight: .regular))
            .foregroundStyle(DSColors.textPrimary)
            .keyboardType(keyboardType)
            .autocorrectionDisabled()

            Rectangle()
                .fill(Color(red: 235 / 255, green: 235 / 255, blue: 238 / 255))
                .frame(height: 1)
                .padding(.top, 4)
        }
    }
}
