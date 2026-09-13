//
//  DSAddressCell.swift
//  DesignSystem
//
//  Ячейка адреса в списке (адрес, детали, редактирование)
//

import SwiftUI

/// Ячейка сохранённого адреса: адрес с деталями (этаж/подъезд/домофон)
/// и кнопка редактирования. Не знает про сеть и модели — принимает
/// готовые строки и колбэк редактирования. Подсветка выбранной ячейки
/// задаётся флагом `isSelected`.
public struct DSAddressCell: View {

    /// Адресная строка.
    private let addressLine: String

    /// Этаж.
    private let floor: String?

    /// Подъезд.
    private let entrance: String?

    /// Код домофона.
    private let intercomCode: String?

    /// Флаг «выбрана ли ячейка».
    private let isSelected: Bool

    /// Действие по нажатию на карандаш (редактирование адреса).
    private let onTapEdit: () -> Void

    public init(
        addressLine: String,
        floor: String?,
        entrance: String?,
        intercomCode: String?,
        isSelected: Bool = false,
        onTapEdit: @escaping () -> Void = {}
    ) {
        self.addressLine = addressLine
        self.floor = floor
        self.entrance = entrance
        self.intercomCode = intercomCode
        self.isSelected = isSelected
        self.onTapEdit = onTapEdit
    }

    private var detailsString: String {
        "\(floor ?? "") этаж, \(entrance ?? "") подъезд, код домофона \(intercomCode ?? "")"
    }

    private var attributedText: AttributedString {
        var result = AttributedString(addressLine + "\n")
        result.font = DSTypography.addressTitle

        var subtitle = AttributedString(detailsString)
        subtitle.font = DSTypography.caption
        subtitle.foregroundColor = DSColors.textSecondary

        result.append(subtitle)
        return result
    }

    public var body: some View {
        HStack {
            Text(attributedText)
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
                .padding(.top, 6)
            Spacer()
            Button(action: onTapEdit) {
                Image(.pencil)
                    .padding(.bottom, 26)
                    .padding(.trailing, 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(isSelected ? DSColors.lightGradient : .linearGradient(colors: [.white], startPoint: .leading, endPoint: .trailing))
        .cornerRadius(12)
        .padding(.horizontal, 12)
    }
}

#Preview("Выбранная") {
    DSAddressCell(
        addressLine: "Новая Басманная ул., 35 ст1, 59",
        floor: "3",
        entrance: "4",
        intercomCode: "15809",
        isSelected: true
    )
    .padding()
}

#Preview("Не выбранная") {
    DSAddressCell(
        addressLine: "Новая Басманная ул., 35 ст1, 59",
        floor: "3",
        entrance: "4",
        intercomCode: "15809"
    )
    .padding()
}
