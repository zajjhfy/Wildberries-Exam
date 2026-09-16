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
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    DSCloseButton(action: onClose, color: .white)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)

                Spacer()

                VStack(alignment: .leading, spacing: 0) {
                    Image(.approve)

                    Text(title)
                        .font(DSTypography.reviewSuccessTitle)
                        .foregroundStyle(.white)
                        .minimumScaleFactor(0.7)
                        .lineLimit(2)
                        .padding(.top, 24)
                        .padding(.bottom, 16)

                    Text(subtitle)
                        .font(DSTypography.reviewSuccessSubtitle)
                        .foregroundStyle(DSColors.reviewSuccessSubtitle)
                        .minimumScaleFactor(0.8)
                        .lineLimit(3)

                    DSButton(
                        action: {
                            onAction()
                            onClose()
                        },
                        buttonTitle: "Закрыть",
                        style: .white
                    )
                    .padding(.top, 28)
                    .padding(.bottom, 16)
                }
                .padding(.horizontal, 16)
            }
            .safeAreaPadding()
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