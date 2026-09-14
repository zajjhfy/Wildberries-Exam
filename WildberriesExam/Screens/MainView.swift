//
//  MainView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import BusinessLogic

struct MainView: View {
    @State var viewModel: CatalogViewModel
    
    var body: some View {
        ZStack {
            CatalogView(viewModel: viewModel)
            SearchView()
        }
    }
}

