//
//  ProductDetail+Product.swift
//  wb-ios-project
//
//

import Foundation

extension ProductDetail {
    var product: Product {
        Product(
            id: id,
            name: name,
            imageURL: imageURL,
            price: price,
            weight: weight,
            rating: rating,
            reviewCount: reviewsCount
        )
    }
}
