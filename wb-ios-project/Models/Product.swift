//
//  Product.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/2/26.
//

import Foundation

struct Product: Identifiable, Codable, Sendable {
    let id: String
    let name: String
    let imageURL: URL?
    let price: Int
    let weight: Double
    let rating: Float
    let reviewCount: Int
}
