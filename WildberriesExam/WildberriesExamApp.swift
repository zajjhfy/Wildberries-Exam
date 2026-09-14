//
//  WildberriesExamApp.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 08.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

@main
struct WildberriesExamApp: App {
    @StateObject var router = AppRouter()
    var appDependencies: AppDependencies!
    
    init() {
        appDependencies = makeAppDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                MainView(viewModel: CatalogViewModel(service: appDependencies.catalogService))
                    .navigationDestination(for: Route.self, destination: { route in
                        destination(for: route)
                    })
            }
            .environmentObject(router)
            
        }
    }
}

extension WildberriesExamApp {
    private func makeAppDependencies() -> AppDependencies {
        do {
            return try AppDependencies()
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    private func destination(for route: Route) -> some View {
        switch route {
        case .category(let id):
            CatalogProductsView(id: id, viewModel: CatalogViewModel(service: appDependencies.catalogService))
        }
    }
}
