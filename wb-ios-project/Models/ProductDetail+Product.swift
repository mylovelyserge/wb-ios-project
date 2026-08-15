//
//  ProductDetail+Product.swift
//  wb-ios-project
//
//  Created by Codex on 8/15/26.
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
