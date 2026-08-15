//
//  RemoteImage.swift
//  wb-ios-project
//
//

import SwiftUI

struct RemoteImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: Image?
    @State private var loadedURL: URL?

    var body: some View {
        Group {
            if let image {
                content(image)
            } else {
                placeholder()
            }
        }
        .task(id: url) {
            await loadImage(from: url)
        }
    }

    private func loadImage(from url: URL?) async {
        guard loadedURL != url || image == nil else { return }

        guard let url else {
            await updateImage(nil, loadedURL: nil)
            return
        }

        let request = URLRequest(url: url)
        if let cachedResponse = URLCache.shared.cachedResponse(for: request),
           let uiImage = UIImage(data: cachedResponse.data) {
            await updateImage(Image(uiImage: uiImage), loadedURL: url)
            return
        }

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let uiImage = UIImage(data: data) else {
                await updateImage(nil, loadedURL: url)
                return
            }

            URLCache.shared.storeCachedResponse(
                CachedURLResponse(response: response, data: data),
                for: request
            )
            await updateImage(Image(uiImage: uiImage), loadedURL: url)
        } catch {
            await updateImage(nil, loadedURL: url)
        }
    }

    @MainActor
    private func updateImage(_ image: Image?, loadedURL: URL?) {
        self.image = image
        self.loadedURL = loadedURL
    }
}
