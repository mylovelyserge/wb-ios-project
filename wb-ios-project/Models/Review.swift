//
//  Review.swift
//  wb-ios-project
//
//

import Foundation

struct Review: Identifiable, Hashable {
    let rating: Int
    let author: String
    let createdAt: Date
    let content: String
    let imageURLs: [URL]

    var id: String {
        "\(author)-\(createdAt.timeIntervalSince1970)-\(content.hashValue)"
    }
}

extension Array where Element == Review {
    var averageRating: Double {
        guard !isEmpty else { return 0 }
        let total = reduce(0) { $0 + $1.rating }
        return Double(total) / Double(count)
    }

    func count(for rating: Int) -> Int {
        filter { $0.rating == rating }.count
    }
}
