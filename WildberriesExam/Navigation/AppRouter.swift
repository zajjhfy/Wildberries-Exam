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

enum Route: Hashable {
    case category(id: String)
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
    @Published var path = NavigationPath()

    @Published var presentedSheet: Sheet?
    @Published var sheetPath = NavigationPath()
    
    // in any tab path modification
    
    func push(_ route: Route) { path.append(route) }
    func pop() { path.pop() }
    func popToRoot() { path.popToRoot() }
    func popTo(_ target: Int) { path.popTo(target) }
    
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
