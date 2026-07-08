//
//  ProductDetail.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/7/26.
//

import Foundation

struct ProductDetail: Identifiable {
    let id: String
    let name: String
    let imageURL: URL?
    let price: Int
    let weight: Double
    let rating: Float
    let description: String
    let reviewsCount: Int
    let isFavorite: Bool
}
