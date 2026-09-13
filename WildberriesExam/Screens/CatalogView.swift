//
//  CatalogView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic
import DesignSystem


/*
 Опять тоже, согласуйте взаимодействие компонентов друг с другом, чтобы не приходилось добавлять Binding прослойки в виде selectedIndexBinding
 Если selectedCategoryID обновляется из-за Binding по нажатию, то зачем делать selectCategory(selectedCategoryID), если можно просто didSet { selectCategory() }
 */
struct CatalogView: View {
    @State var viewModel: CatalogViewModel
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 2)
    private var selectedIndexBinding: Binding<Int> {
        Binding(
            get: {
                guard let id = viewModel.selectedCategoryID,
                      let idx = viewModel.categories.firstIndex(where: { $0.id == id })
                else { return 0 }
                return idx
            },
            set: { newIndex in
                guard viewModel.categories.indices.contains(newIndex) else { return }
                let id = viewModel.categories[newIndex].id
                Task { await viewModel.selectCategory(id) }
            }
        )
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
                    selectedIndex: selectedIndexBinding,
                    tabs: viewModel.categories.map { $0.name }
                )
                .padding(.horizontal)
            }
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(viewModel.products) { product in
                        DSProductCard(product,
                                      onIncrement: {},
                                      onDecrement: {},
                                      onToggleFavorite: {})
                    }
                }
                .padding()
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
        .onAppear {
            Task { await viewModel.load() }
        }
        
    }
}

#Preview {
    let viewModel = CatalogViewModel(service: PreviewCatalogService())
    
    CatalogView(viewModel: viewModel)
}
