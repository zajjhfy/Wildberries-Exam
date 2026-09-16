//
//  AddressSearchSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import CoreLocation
import BusinessLogic
import DesignSystem

public struct AddressSearchSheet: View {
    @EnvironmentObject private var router: AppRouter
    @Environment(AddressesViewModel.self) private var addressesViewModel

    @State private var city: String = ""
    @State private var street: String = ""
    @State private var apartment: String = ""
    @State private var entrance: String = ""
    @State private var floor: String = ""
    @State private var intercomCode: String = ""
    @State private var comment: String = ""

    @State private var isSaving: Bool = false
    @State private var errorMessage: String?

    public init() {}

    public var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                // Header Title
                Text("Введите адрес")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(DSColors.textPrimary)
                    .padding(.top, 24)
                    .padding(.bottom, 6)

                // 7 Form Fields matching Figma design
                ManualAddressField(title: "Город", placeholder: "Город", text: $city)
                ManualAddressField(title: "Улица", placeholder: "Улица", text: $street)
                ManualAddressField(title: "Квартира/офис", placeholder: "Квартира/офис", text: $apartment)
                ManualAddressField(title: "Подъезд", placeholder: "Подъезд", text: $entrance)
                ManualAddressField(title: "Этаж", placeholder: "Этаж", text: $floor)
                ManualAddressField(title: "Код домофона", placeholder: "Код домофона", text: $intercomCode)
                ManualAddressField(title: "Комментарий", placeholder: "Комментарий", text: $comment)

                if let errorMessage {
                    Text(errorMessage)
                        .font(DSTypography.caption)
                        .foregroundStyle(.red)
                        .padding(.top, 4)
                }

                // Save button
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
        .scrollDismissesKeyboard(.immediately)
    }

    private func saveAddress() {
        guard !isSaving else { return }

        var parts: [String] = []
        let trimmedCity = city.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStreet = street.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedApartment = apartment.trimmingCharacters(in: .whitespacesAndNewlines)

        if !trimmedCity.isEmpty { parts.append(trimmedCity) }
        if !trimmedStreet.isEmpty { parts.append(trimmedStreet) }
        if !trimmedApartment.isEmpty {
            if trimmedApartment.lowercased().contains("кв") || trimmedApartment.lowercased().contains("офис") {
                parts.append(trimmedApartment)
            } else {
                parts.append("кв. \(trimmedApartment)")
            }
        }

        let fullAddressLine = parts.joined(separator: ", ")
        guard !fullAddressLine.isEmpty else {
            errorMessage = "Пожалуйста, введите город или улицу"
            return
        }

        isSaving = true
        errorMessage = nil

        Task {
            var coords = AddressCoordinates(longitude: 37.6622, latitude: 55.7667)!
            if let placemarks = try? await CLGeocoder().geocodeAddressString(fullAddressLine),
               let location = placemarks.first?.location,
               let resolved = AddressCoordinates(longitude: location.coordinate.longitude, latitude: location.coordinate.latitude) {
                coords = resolved
            }

            let trimmedFloor = floor.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedEntrance = entrance.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedIntercom = intercomCode.trimmingCharacters(in: .whitespacesAndNewlines)
            let trimmedComment = comment.trimmingCharacters(in: .whitespacesAndNewlines)

            let details = AddressDetails(
                addressLine: fullAddressLine,
                coordinates: coords,
                floor: trimmedFloor.isEmpty ? nil : trimmedFloor,
                entrance: trimmedEntrance.isEmpty ? nil : trimmedEntrance,
                intercomCode: trimmedIntercom.isEmpty ? nil : trimmedIntercom,
                comment: trimmedComment.isEmpty ? nil : trimmedComment
            )

            await addressesViewModel.create(details)

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
