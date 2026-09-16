//
//  AddressMapSheet.swift
//  WildberriesExam
//
//  Created by Иван Коновалов on 13.09.2026.
//

import SwiftUI
import MapKit
import CoreLocation
import DesignSystem
import BusinessLogic

public struct AddressMapSheet: View {
    @EnvironmentObject private var router: AppRouter

    private let mode: AddressMapMode

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.7667, longitude: 37.6622),
            span: MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        )
    )

    @State private var currentCenter: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 55.7667, longitude: 37.6622)
    @State private var currentSpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
    @State private var currentAddressLine: String = "Новая Басманная ул., 35 ст1"
    @State private var currentCoordinates: [Double] = [37.6622, 55.7667]
    @State private var geocodeTask: Task<Void, Never>?

    public init(mode: AddressMapMode = .create) {
        self.mode = mode
    }

    public var body: some View {
        ZStack {
            mapView()
            centerPinView()

            VStack {
                mapControls(
                    onClose: { router.dismissTopSheet() },
                    onZoomIn: { zoomIn() },
                    onZoomOut: { zoomOut() },
                    onLocate: { centerOnLocation() }
                )

                Spacer()

                bottomPanel(
                    onSelect: { handleSelectAddress() },
                    onEnterDifferent: { router.presentSheet(.addressSearch) }
                )
            }
            .zIndex(2)
        }
        .frame(maxHeight: .infinity)
        .onAppear {
            handleAppear()
        }
    }
}

extension AddressMapSheet {
    private func mapView() -> some View {
        Map(position: $position)
            .onMapCameraChange(frequency: .onEnd) { context in
                currentCenter = context.region.center
                currentSpan = context.region.span
                currentCoordinates = [context.region.center.longitude, context.region.center.latitude]
                reverseGeocode(coordinate: context.region.center)
            }
            .ignoresSafeArea()
    }

    private func centerPinView() -> some View {
        DSMapPin()
            .offset(y: -15)
            .allowsHitTesting(false)
            .zIndex(1)
    }

    private func mapControls(
        onClose: @escaping () -> Void,
        onZoomIn: @escaping () -> Void,
        onZoomOut: @escaping () -> Void,
        onLocate: @escaping () -> Void
    ) -> some View {
        HStack {
            Spacer()
            VStack(spacing: 8) {
                DSCloseMapButton(action: onClose)
                    .padding(.bottom, 64)

                DSPlusMapButton(action: onZoomIn)
                DSMinusMapButton(action: onZoomOut)
                DSLocationMapButton(action: onLocate)
            }
            .padding(.trailing, 16)
            .padding(.top, 16)
        }
    }

    private func bottomPanel(
        onSelect: @escaping () -> Void,
        onEnterDifferent: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(currentAddressLine)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(DSColors.textPrimary)
                .lineLimit(2)

            if case .create = mode {
                HStack(spacing: 12) {
                    DSButton(
                        action: onEnterDifferent,
                        buttonTitle: "Ввести другой",
                        style: .inputAddress
                    )

                    DSButton(
                        action: onSelect,
                        buttonTitle: "Выбрать адрес",
                        style: .accent
                    )
                }
            } else {
                DSButton(
                    action: onSelect,
                    buttonTitle: "Выбрать адрес",
                    style: .accent
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 28)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Color.white
                .clipShape(UnevenRoundedRectangle(
                    topLeadingRadius: 24,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 24,
                    style: .continuous
                ))
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: -4)
        )
    }

    private func handleAppear() {
        if case let .pickLocation(initialCenter) = mode, let initialCenter, initialCenter.count >= 2 {
            let coord = CLLocationCoordinate2D(latitude: initialCenter[1], longitude: initialCenter[0])
            currentCenter = coord
            currentCoordinates = initialCenter
            position = .region(MKCoordinateRegion(center: coord, span: currentSpan))
            reverseGeocode(coordinate: coord)
        }
    }

    private func handleSelectAddress() {
        if case .create = mode {
            router.presentSheet(.addressDetails(mode: .createFromMap(
                addressLine: currentAddressLine,
                coordinates: currentCoordinates
            )))
        } else {
            router.selectedMapLocation = SelectedMapLocation(
                addressLine: currentAddressLine,
                coordinates: currentCoordinates
            )
            router.dismissTopSheet()
        }
    }

    private func zoomIn() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: max(currentSpan.latitudeDelta / 2.0, 0.001),
            longitudeDelta: max(currentSpan.longitudeDelta / 2.0, 0.001)
        )
        currentSpan = newSpan
        withAnimation(.easeInOut(duration: 0.25)) {
            position = .region(MKCoordinateRegion(center: currentCenter, span: newSpan))
        }
    }

    private func zoomOut() {
        let newSpan = MKCoordinateSpan(
            latitudeDelta: min(currentSpan.latitudeDelta * 2.0, 1.0),
            longitudeDelta: min(currentSpan.longitudeDelta * 2.0, 1.0)
        )
        currentSpan = newSpan
        withAnimation(.easeInOut(duration: 0.25)) {
            position = .region(MKCoordinateRegion(center: currentCenter, span: newSpan))
        }
    }

    private func centerOnLocation() {
        let target = CLLocationCoordinate2D(latitude: 55.7667, longitude: 37.6622)
        let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
        currentCenter = target
        currentSpan = defaultSpan
        withAnimation(.easeInOut(duration: 0.35)) {
            position = .region(MKCoordinateRegion(center: target, span: defaultSpan))
        }
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        geocodeTask?.cancel()
        geocodeTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)
            guard !Task.isCancelled else { return }

            let geocoder = CLGeocoder()
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

            if let placemarks = try? await geocoder.reverseGeocodeLocation(location),
               let place = placemarks.first {
                let formatted = formatAddress(placemark: place)
                await MainActor.run {
                    self.currentAddressLine = formatted
                }
            }
        }
    }

    private func formatAddress(placemark: CLPlacemark) -> String {
        var components: [String] = []

        if let name = placemark.name {
            components.append(name)
        } else if let thoroughfare = placemark.thoroughfare {
            var street = thoroughfare
            if let subThoroughfare = placemark.subThoroughfare {
                street += ", \(subThoroughfare)"
            }
            components.append(street)
        }

        if let city = placemark.locality {
            components.append(city)
        }

        return components.isEmpty ? "Басманный район, Москва" : components.joined(separator: ", ")
    }
}
