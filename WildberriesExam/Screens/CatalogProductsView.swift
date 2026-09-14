//
//  CatalogProductsView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem

struct CatalogProductsView: View {
    @State private var viewModel: CatalogViewModel
    @State private var categoryName: String
    
    private let id: String
    private var prefetchThreshold: CGFloat
    
    init(id: String, viewModel: CatalogViewModel) {
        self.id = id
        self.viewModel = viewModel
        self.categoryName = ""
        self.prefetchThreshold = 200
    }
    
    var body: some View {
        VStack {
            if viewModel.state == .loading {
                loadingState()
            } else if case let .failed(error) = viewModel.state {
                errorState(error)
            } else {
                ScrollView {
                    products()
                }
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
        .task {
            await viewModel.selectCategory(id)
            await viewModel.refresh()
            guard let name = viewModel.categories.first(where: { $0.id == id })?.name else { return }
            categoryName = name
        }
        .navigationTitle(categoryName)
        .navigationBarTitleDisplayMode(.large)
    }
}

extension CatalogProductsView {
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
