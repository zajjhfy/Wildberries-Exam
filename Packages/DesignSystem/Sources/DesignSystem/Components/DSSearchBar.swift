//
//  DSSearchBar.swift
//  DesignSystem
//
//  Строка поиска
//

import SwiftUI

/// Строка поиска с иконкой и текстовым полем.
/// Фокус синхронизируется через `isFocused`.
public struct DSSearchBar: View {

    private let action: () -> Void
    private let searchText: Binding<String>
    @Binding private var isFocused: Bool

    @FocusState private var focusState: Bool

    public init(
        searchText: Binding<String>,
        isFocused: Binding<Bool>,
        action: @escaping () -> Void
    ) {
        self.searchText = searchText
        self._isFocused = isFocused
        self.action = action
    }

    public var body: some View {
        HStack {
            Image(.search)
            TextField("Поиск", text: searchText)
                .focused($focusState)
                .onSubmit { action() }
                .onChange(of: focusState) { _, newValue in
                    isFocused = newValue
                }
                .onChange(of: isFocused) { _, newValue in
                    focusState = newValue
                }
        }
        .padding(10)
        .background(DSColors.searchBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    DSColors.textSecondary.opacity(0.3),
                    lineWidth: 1
                )
        )
    }
}

#Preview {
    DSSearchBar(
        searchText: .constant(""),
        isFocused: .constant(false)
    ) {}
        .padding()
}
