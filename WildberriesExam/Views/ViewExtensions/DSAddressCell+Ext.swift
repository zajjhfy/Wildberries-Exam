//
//  DSAddressCell+Ext.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import Foundation
import DesignSystem
import BusinessLogic

extension DSAddressCell {
    public init(
        address: DeliveryAddress,
        isSelected: Bool,
        onTapEdit: @escaping () -> Void
    ) {
        self.init(
            addressLine: address.details.addressLine,
            floor: address.details.floor,
            entrance: address.details.entrance,
            intercomCode: address.details.intercomCode,
            isSelected: isSelected,
            onTapEdit: onTapEdit
        )
    }
}
