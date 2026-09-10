//
//  DSAsyncImage.swift
//  DesignSystem
//
//  Асинхронная загрузка и кэширование изображений по URL
//

import SwiftUI

/// Асинхронное изображение с кэшированием в памяти.
/// - Пока грузится — показывает `ProgressView`.
/// - При успехе — вызывает `content(Image)`.
/// - При ошибке/пустом URL — показывает `placeholder()`.
///
/// Самодостаточный: не зависит от сетевых сервисов приложения,
/// использует собственный кэш в памяти и `URLSession`.
public struct DSAsyncImage<Content: View, Placeholder: View>: View {

    private let urlString: String
    @ViewBuilder private let content: (Image) -> Content
    @ViewBuilder private let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = false

    public init(
        urlString: String,
        @ViewBuilder content: @escaping (Image) -> Content,
        @ViewBuilder placeholder: @escaping () -> Placeholder
    ) {
        self.urlString = urlString
        self.content = content
        self.placeholder = placeholder
    }

    public var body: some View {
        Group {
            if let image {
                content(Image(uiImage: image))
            } else if isLoading {
                ProgressView()
            } else {
                placeholder()
            }
        }
        .task(id: urlString) {
            guard !urlString.isEmpty else { return }
            isLoading = true
            image = await DSImageCache.shared.load(from: urlString)
            isLoading = false
        }
    }
}

/// Кэш изображений в памяти с дедупликацией одновременных запросов.
actor DSImageCache {

    static let shared = DSImageCache()

    private let cache = NSCache<NSString, UIImage>()
    private var inFlight: [String: Task<UIImage?, Never>] = [:]

    func load(from urlString: String) async -> UIImage? {
        if let cached = cache.object(forKey: urlString as NSString) {
            return cached
        }
        if let existing = inFlight[urlString] {
            return await existing.value
        }

        let task = Task<UIImage?, Never> { await fetch(from: urlString) }
        inFlight[urlString] = task
        let result = await task.value
        inFlight[urlString] = nil
        return result
    }

    private func fetch(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
        guard let image = UIImage(data: data) else { return nil }
        cache.setObject(image, forKey: urlString as NSString)
        return image
    }
}

#Preview {
    DSAsyncImage(
        urlString: "https://eat-and-pay.t02.ru/uploads/eats-jxl/bread.jxl",
        content: { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
        },
        placeholder: {
            Color(DSColors.cardBackground)
        }
    )
    .frame(width: 200, height: 200)
}
