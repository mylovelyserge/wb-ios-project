//
//  RemoteImage.swift
//  wb-ios-project
//

import SwiftUI

struct RemoteImage<Content: View, Placeholder: View>: View {
    let url: URL?
    @ViewBuilder let content: (Image) -> Content
    @ViewBuilder let placeholder: () -> Placeholder

    @State private var image: Image?
    @State private var loadedURL: URL?
    @State private var isLoading = false

    var body: some View {
        Group {
            if let image {
                content(image)
            } else {
                ZStack {
                    placeholder()
                    if isLoading {
                        ProgressView()
                            .controlSize(.small)
                    }
                }
            }
        }
        .task(id: url) {
            await loadImage(from: url)
        }
    }

    private func loadImage(from url: URL?) async {
        guard loadedURL != url || image == nil else { return }

        guard let url else {
            updateImage(nil, loadedURL: nil)
            return
        }

        setLoading(true)
        let uiImage = await RemoteImageCache.shared.image(for: url)
        updateImage(uiImage.map(Image.init(uiImage:)), loadedURL: url)
        setLoading(false)
    }

    private func updateImage(_ image: Image?, loadedURL: URL?) {
        self.image = image
        self.loadedURL = loadedURL
    }

    private func setLoading(_ isLoading: Bool) {
        self.isLoading = isLoading
    }
}
