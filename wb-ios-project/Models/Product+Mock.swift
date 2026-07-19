//
//  Product+Mock.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/2/26.
//

import Foundation

extension Product {
    static let mocks: [Product] = [
        Product(id: "1",
                name: "Ватрушка",
                imageURL: nil,
                price: 50,
                weight: 120.0,
                rating: 4.9,
                reviewCount: 27),
        Product(id: "2",
                name: "Супчик",
                imageURL: nil,
                price: 100,
                weight: 140.0,
                rating: 4.2,
                reviewCount: 19),
        Product(id: "3",
                name: "Салат",
                imageURL: nil,
                price: 75,
                weight: 80.0,
                rating: 5.0,
                reviewCount: 201),
        Product(id: "4",
                name: "Кофе",
                imageURL: nil,
                price: 40,
                weight: 250.0,
                rating: 4.3,
                reviewCount: 40),
        Product(id: "5",
                name: "Яблоки",
                imageURL: nil,
                price: 25,
                weight: 500.0,
                rating: 4.1,
                reviewCount: 350),
    ]
}
