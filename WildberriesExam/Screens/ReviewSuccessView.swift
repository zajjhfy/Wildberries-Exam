//
//  ReviewSuccessView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem

public struct ReviewSuccessView: View {
    @EnvironmentObject private var router: AppRouter

    public init() {}

    public var body: some View {
        DSSuccessView(
            title: "Отзыв отправлен",
            subtitle: "Спасибо!\nСкоро мы его опубликуем",
            onAction: {
                handleDismiss()
            },
            onClose: {
                handleDismiss()
            }
        )
    }
}

extension ReviewSuccessView {
    private func handleDismiss() {
        router.dismissTopSheet()
    }
}
