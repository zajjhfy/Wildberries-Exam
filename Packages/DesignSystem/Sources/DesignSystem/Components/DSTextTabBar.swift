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
    @State private var scrollInfo = ScrollInfo()
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
                        Text(title)
                            .font(DSTypography.tabBarTitle)
                            .foregroundStyle(
                                selectedIndex == index
                                    ? DSColors.textPrimary
                                    : DSColors.textSecondary
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .onScrollGeometryChange(for: ScrollInfo.self) { geometry in
            ScrollInfo(
                offset: geometry.contentOffset.x + geometry.contentInsets.leading,
                maxOffset: geometry.contentSize.width
                    - geometry.containerSize.width
                    + geometry.contentInsets.trailing
            )
        } action: { _, newValue in
            scrollInfo = newValue
        }
        .overlay(alignment: .leading) {
            if scrollInfo.offset > 0 {
                fadeGradient(startPoint: .leading, endPoint: .trailing)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: scrollInfo.offset > 0)
    }

    private struct ScrollInfo: Equatable {
        var offset: CGFloat = 0
        var maxOffset: CGFloat = 0
    }

    @ViewBuilder
    private func fadeGradient(
        startPoint: UnitPoint,
        endPoint: UnitPoint
    ) -> some View {
        DSColors.textTabBarGradient
            .frame(width: 50, height: 52)
            .allowsHitTesting(false)
            .rotationEffect(Angle(degrees: -180))
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
