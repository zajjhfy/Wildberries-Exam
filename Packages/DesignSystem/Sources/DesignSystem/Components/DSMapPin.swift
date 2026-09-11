//
//  DSMapPin.swift
//  DesignSystem
//
//  Пин на карте с временем доставки
//

import SwiftUI

public struct DSMapPin: View {

    public init() {}

    public var body: some View {
        VStack(spacing: 2) {
            Text("15 мин")
                .foregroundStyle(.white)
                .frame(width: 71, height: 24)
                .background(
                    PinShape()
                        .fill(DSColors.accentGradient)
                )
                .overlay(
                    PinShape()
                        .stroke(Color.white)
                )
        }
    }
}

public struct PinShape: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(
            center: CGPoint(x: rect.maxX - 10, y: rect.maxY - 10),
            radius: 10,
            startAngle: Angle(degrees: 0),
            endAngle: Angle(degrees: 90),
            clockwise: false
        )
        path.addLine(to: CGPoint(x: rect.midX + 8, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + 10))
        path.addLine(to: CGPoint(x: rect.midX - 8, y: rect.maxY))
        path.addArc(
            center: CGPoint(x: rect.minX + 10, y: rect.maxY - 10),
            radius: 10,
            startAngle: Angle(degrees: 90),
            endAngle: Angle(degrees: 180),
            clockwise: false
        )

        path.addArc(
            center: CGPoint(x: rect.minX + 10, y: rect.minY + 10),
            radius: 10,
            startAngle: Angle(degrees: 180),
            endAngle: Angle(degrees: 270),
            clockwise: false
        )

        path.addArc(
            center: CGPoint(x: rect.maxX - 10, y: rect.minY + 10),
            radius: 10,
            startAngle: Angle(degrees: 270),
            endAngle: Angle(degrees: 360),
            clockwise: false
        )

        path.closeSubpath()
        return path
    }
}

public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    DSMapPin()
}