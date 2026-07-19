//
//  CartItem.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/12/26.
//

import Foundation

struct CartItem: Identifiable {
    var product: Product
    var id: String {product.id}
    var quantity: Int
}
