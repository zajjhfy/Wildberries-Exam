//
//  OrderSuccessOverlay.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem

public struct OrderSuccessOverlay: View {
    @EnvironmentObject private var router: AppRouter

    public init() {}

    public var body: some View {
        DSSuccessView(
            title: "Заказ оформлен",
            subtitle: "Товары уже в процессе сборки,\nскоро привезём!",
            onAction: {
                router.dismissAllSheets()
            },
            onClose: {
                router.dismissAllSheets()
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(height: 380)
        .transition(.scale(scale: 0.85).combined(with: .opacity))
    }
}
