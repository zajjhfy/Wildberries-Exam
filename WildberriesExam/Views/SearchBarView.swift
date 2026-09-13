//
//  SearchBarView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import DesignSystem

#warning("DesignSystem: add xmark. Можно дернуть SearchBarView и добавить его в DesignSystem")
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

                Button(action: {
                    collapse()
                }, label: {
                    RoundedRectangle(cornerRadius: 12)
                        .overlay {
                            Image(systemName: "xmark")
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .font(DSTypography.searchButtonTitle)
                                .foregroundStyle(.black)
                        }
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.primary)
                })
                .buttonStyle(.plain)
                .transition(.opacity)
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
