//
//  DSFormField.swift
//  DesignSystem
//
//  Поле формы с заголовком/подписью
//

import SwiftUI

/// Поле формы: подпись (caption, серый) над `TextField`.
/// Поддерживает блокировку с иконкой замка и настраиваемый отступ сверху.
public struct DSFormField: View {

    /// Подпись поля.
    private let title: String

    /// Текст-плейсхолдер.
    private let placeholder: String

    /// Привязка значения поля.
    @Binding private var text: String

    /// Флаг блокировки поля.
    private let isDisabled: Bool

    /// Показывать иконку замка слева.
    private let showsLock: Bool

    /// Отступ подписи сверху.
    private let topPadding: CGFloat

    public init(
        _ title: String,
        placeholder: String = "",
        text: Binding<String>,
        isDisabled: Bool = false,
        showsLock: Bool = false,
        topPadding: CGFloat = 24
    ) {
        self.title = title
        self.placeholder = placeholder
        self._text = text
        self.isDisabled = isDisabled
        self.showsLock = showsLock
        self.topPadding = topPadding
    }

    public var body: some View {
        Section(header: Text(title)
            .font(DSTypography.caption)
            .foregroundStyle(Color.secondary)
            .padding(.top, topPadding)) {
            HStack(spacing: 8) {
                if showsLock {
                    Image(.lock)
                        .foregroundStyle(Color.secondary)
                }
                TextField(placeholder, text: $text)
                    .disabled(isDisabled)
                    .foregroundStyle(isDisabled ? Color.secondary : Color.primary)
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading) {
        DSFormField("Имя", text: .constant("Иван"))
        Divider()
        DSFormField(
            "Телефон",
            placeholder: "+7 900 000-00-00",
            text: .constant("+7 900 000-00-00"),
            isDisabled: true,
            showsLock: true
        )
        Divider()
        DSFormField("День рождения", text: .constant("13.09.1998"))
    }
    .padding(.horizontal, 12)
}

#Preview("Тёмная") {
    VStack(alignment: .leading) {
        DSFormField("Имя", text: .constant("Иван"))
        Divider()
        DSFormField(
            "Телефон",
            placeholder: "+7 900 000-00-00",
            text: .constant("+7 900 000-00-00"),
            isDisabled: true,
            showsLock: true
        )
    }
    .padding(.horizontal, 12)
    .preferredColorScheme(.dark)
}