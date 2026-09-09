//
//  RemoteImageCache.swift
//  wb-ios-project
//

import Foundation
import UIKit

actor RemoteImageCache {
    static let shared = RemoteImageCache()

    private var images: [URL: UIImage] = [:]
    private var inFlightTasks: [URL: Task<UIImage?, Never>] = [:]
    private let session = URLSession.shared

    func image(for url: URL) async -> UIImage? {
        if let image = images[url] {
            return image
        }

        if let task = inFlightTasks[url] {
            return await task.value
        }

        let task = Task<UIImage?, Never> { [session] in
            let request = URLRequest(url: url)

            if let cachedResponse = URLCache.shared.cachedResponse(for: request),
               let image = UIImage(data: cachedResponse.data) {
                return image
            }

            do {
                let (data, response) = try await session.data(for: request)
                guard let image = UIImage(data: data) else { return nil }

                URLCache.shared.storeCachedResponse(
                    CachedURLResponse(response: response, data: data),
                    for: request
                )
                return image
            } catch {
                return nil
            }
        }

        inFlightTasks[url] = task
        let image = await task.value
        inFlightTasks[url] = nil

        if let image {
            images[url] = image
        }

        return image
    }

    func prefetch(_ urls: [URL]) async {
        let uniqueURLs = Array(Set(urls))
        await withTaskGroup(of: Void.self) { group in
            for url in uniqueURLs {
                group.addTask {
                    _ = await self.image(for: url)
                }
            }
        }
    }
}
