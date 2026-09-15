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
    
    @EnvironmentObject var router: AppRouter
    @State private var viewModel: CatalogViewModel
    @State private var selectedTab: Tab
    
    private var prefetchThreshold: CGFloat
    
    init(viewModel: CatalogViewModel) {
        self.viewModel = viewModel
        self.selectedTab = .forYou
        self.prefetchThreshold = 400
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
                loadingState()
            } else if case let .failed(error) = viewModel.state {
                errorState(error)
            } else {
                ScrollView {
                    switch selectedTab {
                    case .forYou:
                        products()
                    case .catalog:
                        catalog(selectedCategoryAction: { id in
                            router.push(.category(id: id))
                        })
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
    @ViewBuilder
    private func loadingState() -> some View {
        Spacer()
        ProgressView()
        Spacer()
    }
    
    @ViewBuilder
    private func errorState(_ errorDescription: String) -> some View {
        Spacer()
        Text(errorDescription)
            .font(DSTypography.caption)
        Spacer()
    }
    
    private func blank() -> some View {
        Text("Тут пока ничего нет :(")
            .font(DSTypography.caption)
    }
    
    private func catalog(selectedCategoryAction: @escaping (String) -> Void) -> some View {
        let columns = Array(repeating: GridItem(.flexible()), count: 3)
        
        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(viewModel.categories) { category in
                Button {
                    selectedCategoryAction(category.id)
                } label: {
                    DSCategoryCard(category)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
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
    }
}

#Preview {
    let viewModel = CatalogViewModel(service: PreviewCatalogService())
    
    CatalogView(viewModel: viewModel)
}
