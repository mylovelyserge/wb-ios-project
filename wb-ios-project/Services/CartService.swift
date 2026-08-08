//
//  CartService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/12/26.
//

import Foundation
import Observation

@Observable
final class CartService {
    private(set) var quantities: [String: Int] = [:]
    private(set) var products: [String: Product] = [:]
    
    func add(product: Product) {
        quantities[product.id, default: 0] += 1
        products[product.id] = product
    }
    
    func increase(productId: String) {
        quantities[productId, default: 0] += 1
    }
    
    func decrease(productId: String) {
        guard let current = quantities[productId] else {return}
        if current > 1 {
            quantities[productId] = current - 1
        } else {
            quantities[productId] = nil
            products[productId] = nil
        }
    }
    
    func remove(productId: String) {
        quantities[productId] = nil
        products[productId] = nil
    }
    
    var totalCount: Int {
        quantities.values.reduce(0, +)
    }
    
    var totalPrice: Int {
        quantities.reduce(0) { sum, pair in
            let price = products[pair.key]?.price ?? 0
            return sum + price * pair.value
        }
    }
    
    var items: [CartItem] {
        quantities.sorted { $0.key < $1.key }.compactMap { pair in
            guard let product = products[pair.key] else { return nil }
            return CartItem(product: product, quantity: pair.value)
        }
    }
}
