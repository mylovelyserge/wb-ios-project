//
//  ProductDetail+Mock.swift
//  wb-ios-project
//
//

import Foundation

extension ProductDetail {
    static func mock(for productId: String) -> ProductDetail {
        let product = Product.mocks.first { $0.id == productId } ?? Product.mocks[0]
        let reviews = Review.mocks

        return ProductDetail(
            id: product.id,
            name: product.name,
            imageURL: product.imageURL,
            price: product.price,
            weight: product.weight,
            rating: Float(reviews.averageRating),
            description: "Описание товара временно показано из тестовых данных, потому что backend не ответил вовремя.",
            reviews: reviews,
            reviewsCount: reviews.count,
            isFavorite: false
        )
    }
}

extension Review {
    static let mocks: [Review] = [
        Review(
            rating: 5,
            author: "Дарья",
            createdAt: Date(timeIntervalSinceNow: -86400 * 6),
            content: "Заказывала этот бутерброд на завтрак, когда не было времени готовить. Очень понравилось качество хлеба и свежий вкус.",
            imageURLs: []
        ),
        Review(
            rating: 4,
            author: "Александр",
            createdAt: Date(timeIntervalSinceNow: -86400 * 11),
            content: "Хороший вариант для быстрого перекуса. Хотелось бы чуть больше начинки.",
            imageURLs: []
        )
    ]
}
