//
//  SplashScreenView.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 16.09.2026.
//

import SwiftUI
import DesignSystem

public struct SplashScreenView: View {
    public init() {}

    public var body: some View {
        LinearGradient(
            stops: [
                .init(color: Color(red: 0.93, green: 0.24, blue: 0.79), location: 0.0049),
                .init(color: Color(red: 0.87, green: 0.20, blue: 0.82), location: 0.1488),
                .init(color: Color(red: 0.82, green: 0.17, blue: 0.85), location: 0.2927),
                .init(color: Color(red: 0.75, green: 0.13, blue: 0.88), location: 0.4314),
                .init(color: Color(red: 0.68, green: 0.10, blue: 0.91), location: 0.5702),
                .init(color: Color(red: 0.60, green: 0.06, blue: 0.94), location: 0.7089),
                .init(color: Color(red: 0.51, green: 0.02, blue: 0.97), location: 0.8476),
                .init(color: Color(red: 0.40, green: 0.00, blue: 1.00), location: 0.9915),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}
