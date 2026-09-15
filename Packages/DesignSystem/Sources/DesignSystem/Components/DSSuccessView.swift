//
//  DSSuccessView.swift
//  DesignSystem
//
//  Экран успеха (после отправки отзыва / заказа)
//

import SwiftUI

/// Полноэкранный экран успеха на брендовом градиенте: галочка,
/// заголовок, подсказка и кнопка «Закрыть». Ничего не знает про
/// навигацию — принимает тексты и колбэки действий.
public struct DSSuccessView: View {

    /// Заголовок экрана.
    private let title: String

    /// Подсказка под заголовком.
    private let subtitle: String

    /// Действие по кнопке «Закрыть» (вызывается перед `onClose`).
    private let onAction: () -> Void

    /// Закрытие экрана (крестик и кнопка «Закрыть»).
    private let onClose: () -> Void

    public init(
        title: String = "Отзыв отправлен",
        subtitle: String = "Спасибо!\nСкоро мы его опубликуем",
        onAction: @escaping () -> Void = {},
        onClose: @escaping () -> Void = {}
    ) {
        self.title = title
        self.subtitle = subtitle
        self.onAction = onAction
        self.onClose = onClose
    }

    public var body: some View {
        ZStack {
            DSColors.accentGradient
                .ignoresSafeArea()
            DSCloseButton(action: onClose, color: .white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.top, 12)
                .padding(.trailing, 12)
            VStack(alignment: .leading) {
                Spacer()
                Image(.approve)
                Text(title)
                    .font(DSTypography.reviewSuccessTitle)
                    .foregroundStyle(.white)
                    .padding(.top, 16)
                    .padding(.bottom, 16)
                Text(subtitle)
                    .font(DSTypography.reviewSuccessSubtitle)
                    .foregroundStyle(DSColors.reviewSuccessSubtitle)
                DSButton(
                    action: {
                        onAction()
                        onClose()
                    },
                    buttonTitle: "Закрыть",
                    style: .white
                )
                .padding(.bottom, 12)
                .padding(.top, 20)
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview {
    DSSuccessView()
}

#Preview("Тёмная") {
    DSSuccessView()
        .preferredColorScheme(.dark)
}