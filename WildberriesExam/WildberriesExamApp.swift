//
//  WildberriesExamApp.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 08.09.2026.
//

import SwiftUI
import DesignSystem
import BusinessLogic

#warning("Design system: Add basket.fill")
@main
struct WildberriesExamApp: App {
    @StateObject var router = AppRouter()
    var appDependencies: AppDependencies!
    
    init() {
        appDependencies = makeAppDependencies()
    }
    
    var body: some Scene {
        WindowGroup {
            TabView(selection: $router.selectedTab) {
                Tab("Каталог", systemImage: "basket.fill", value: Tabs.main) {
                    MainView(viewModel: CatalogViewModel(service: appDependencies.catalogService))
                }
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
}
