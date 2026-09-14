//
//  SearchBarView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem

struct SearchBarView: View {
    @State private var isSearching = false
    @State private var isFocused = false
    @Binding private var searchText: String
    
    private let onSubmit: () -> Void

    init(
        searchText: Binding<String>,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._searchText = searchText
        self.onSubmit = onSubmit
    }

    var body: some View {
        HStack(spacing: 8) {
            if isSearching {
                DSSearchBar(searchText: $searchText, isFocused: $isFocused, action: onSubmit)
                    .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .leading)))

                closeButton {
                    collapse()
                }
            } else {
                DSSearchButton {
                    expand()
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95, anchor: .leading)))
            }
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isSearching)
    }

}

extension SearchBarView {
    private func closeButton(_ action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }, label: {
            RoundedRectangle(cornerRadius: 12)
                .overlay {
                    Image(systemName: "xmark")
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .font(DSTypography.searchButtonTitle)
                        .foregroundStyle(.black)
                }
                .frame(width: 55, height: 55)
                .foregroundStyle(DSColors.searchBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(DSColors.textSecondary.opacity(0.3), lineWidth: 1)
                }
        })
        .buttonStyle(.plain)
        .transition(.opacity)
    }
    
    
    private func expand() {
        isSearching = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isFocused = true
        }
    }

    private func collapse() {
        isFocused = false
        searchText = ""
        isSearching = false
    }
}

#Preview {
    HStack {
        SearchBarView(searchText: .constant(""))
            .padding()
        Spacer()
    }
    
}
