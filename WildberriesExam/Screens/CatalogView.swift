//
//  CatalogView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

struct CatalogView: View {
    @State var viewModel: CatalogViewModel
    @State private var selectedTab: Tab = .forYou
    
    enum Tab: Int, CaseIterable {
        case forYou, catalog, discounts, favorites, orderedBefore
        
        var title: String {
            switch self {
            case .forYou: "Для тебя"
            case .catalog: "Каталог"
            case .discounts: "Скидки"
            case .favorites: "Избранное"
            case .orderedBefore: "Уже заказывали"
            }
        }
    }
    
    @State private var isNearBottom = false
    private var prefetchThreshold: CGFloat = 400
    
    init(viewModel: CatalogViewModel, isNearBottom: Bool = false, prefetchThreshold: CGFloat = 400) {
        self.viewModel = viewModel
        self.isNearBottom = isNearBottom
        self.prefetchThreshold = prefetchThreshold
    }
    
    var body: some View {
        VStack {
            if !viewModel.categories.isEmpty {
                DSTextTabBar(
                    selectedIndex: Binding(
                        get: { selectedTab.rawValue },
                        set: { selectedTab = Tab(rawValue: $0) ?? .forYou }
                    ),
                    tabs: Tab.allCases.map(\.title)
                )
                .padding(.horizontal)
            }
            
            if viewModel.state == .loading {
                Spacer()
                ProgressView()
                Spacer()
            } else if case let .failed(error) = viewModel.state {
                Spacer()
                Text(error)
                    .font(DSTypography.caption)
                Spacer()
            } else {
                ScrollView {
                    
                    switch selectedTab {
                    case .forYou:
                        products()
                    case .catalog:
                        dynamicCatalog()
                    case .discounts:
                        blank()
                    case .favorites:
                        blank()
                    case .orderedBefore:
                        blank()
                    }

                }
                .contentMargins(.bottom, 74, for: .scrollContent)
                .onScrollGeometryChange(for: Bool.self) { geometry in
                    let distanceFromBottom = geometry.contentSize.height
                    - geometry.visibleRect.maxY
                    return distanceFromBottom < prefetchThreshold
                } action: { wasNearBottom, isNowNearBottom in
                    guard isNowNearBottom, !wasNearBottom else { return }
                    Task { await viewModel.loadNextPage() }
                }
            }
        }
        .onChange(of: selectedTab) { prev, now in
            if now == .forYou || now == .catalog {
                Task {
                    await viewModel.selectCategory(nil)
                    await viewModel.refresh()
                }
            }
        }
        .onAppear {
            Task { await viewModel.refresh() }
        }
    }
}

extension CatalogView {
    private func blank() -> some View {
        Text("Тут пока ничего нет :(")
            .font(DSTypography.caption)
    }
    
    @ViewBuilder
    private func dynamicCatalog() -> some View {
        if viewModel.selectedCategoryID != nil {
            products()
        } else {
            catalog()
        }
    }
    
    private func catalog() -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        
        return LazyVGrid(columns: columns) {
            ForEach(viewModel.categories) { category in
                DSCategoryCard(category)
                    .onTapGesture {
                        Task { await viewModel.selectCategory(category.id) }
                    }
            }
            .padding()
        }
    }
    
    private func products() -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 2)
        
        return LazyVGrid(columns: columns) {
            ForEach(viewModel.products) { product in
                DSProductCard(product,
                              onIncrement: {},
                              onDecrement: {},
                              onToggleFavorite: {})
            }
        }
        .padding()
    }
}

#Preview {
    let viewModel = CatalogViewModel(service: PreviewCatalogService())
    
    CatalogView(viewModel: viewModel)
}
