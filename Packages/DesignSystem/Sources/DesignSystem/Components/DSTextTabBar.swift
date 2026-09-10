//
//  DSTextTabBar.swift
//  DesignSystem
//
//  Горизонтальный таб-бар из текстовых кнопок
//

import SwiftUI

/// Горизонтальный таб-бар из текстовых вкладок.
/// Выбранная вкладка подсвечивается, переключение — анимированное.
public struct DSTextTabBar: View {

    @Binding public var selectedIndex: Int
    public let tabs: [String]

    public init(selectedIndex: Binding<Int>, tabs: [String]) {
        self._selectedIndex = selectedIndex
        self.tabs = tabs
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 24) {
                ForEach(Array(tabs.enumerated()), id: \.offset) { index, title in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedIndex = index
                        }
                    } label: {
                        VStack(spacing: 4) {
                            Text(title)
                                .font(DSTypography.tabBarTitle)
                                .foregroundStyle(
                                    selectedIndex == index
                                        ? DSColors.textPrimary
                                        : DSColors.textSecondary
                                )
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedTab = 0

        var body: some View {
            VStack {
                DSTextTabBar(
                    selectedIndex: $selectedTab,
                    tabs: ["Для тебя", "Каталог", "Скидки", "Избранное"]
                )
                Spacer()
            }
            .padding(.top, 16)
        }
    }

    return PreviewWrapper()
}