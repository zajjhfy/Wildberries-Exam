//
//  AppRouter.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//
//
//  AppRouter.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import Combine

enum Tabs: Hashable, CaseIterable {
    case main
}

enum Route: Hashable {
    
}

enum Sheet: Identifiable {

    var id: String {
        switch self {
        }
    }
}

enum SheetRoute: Hashable {
}

@MainActor
final class AppRouter: ObservableObject {

    @Published var paths: [Tabs: NavigationPath] = Dictionary(
        uniqueKeysWithValues: Tabs.allCases.map { ($0, NavigationPath()) }
    )

    @Published var selectedTab: Tabs = .main

    @Published var presentedSheet: Sheet?
    @Published var sheetPath = NavigationPath()
    
    // in any tab path modification
    
    func push(_ route: Route, in tab: Tabs) { paths[tab]?.append(route) }
    func pop(in tab: Tabs) { paths[tab]?.pop() }
    func popToRoot(in tab: Tabs) { paths[tab]?.popToRoot() }
    func popTo(count: Int, in tab: Tabs) { paths[tab]?.popTo(count) }
    
    // in current tab path modification
    
    func push(_ route: Route) { push(route, in: selectedTab) }
    func pop() { pop(in: selectedTab) }
    func popToRoot() { popToRoot(in: selectedTab) }
    func popTo(count: Int) { popTo(count: count, in: selectedTab) }
    
    // sheet related
    
    func presentSheet(_ sheet: Sheet) { presentedSheet = sheet }
    func dismissSheet() { presentedSheet = nil }

    func pushInSheet(_ route: SheetRoute) { sheetPath.append(route) }
    func popInSheet() { sheetPath.pop() }
    func popToRootInSheet() { sheetPath.popToRoot() }
    func popToInSheet(count: Int) { sheetPath.popTo(count) }
}

extension NavigationPath {
    mutating func pop() {
        guard !isEmpty else { return }
        removeLast()
    }

    mutating func popTo(_ target: Int) {
        guard target <= count else { return }
        removeLast(count - target)
    }

    mutating func popToRoot() {
        removeLast(count)
    }
}
