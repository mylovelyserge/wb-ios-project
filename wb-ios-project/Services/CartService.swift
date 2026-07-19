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
    private(set) var items: [CartItem] = []
    
    func add(product: Product) {
        if let index = items.firstIndex(where: {$0.product.id == product.id}) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func increase(product: Product) {
        if let index = items.firstIndex(where: {$0.product.id == product.id}) {
            items[index].quantity += 1
        }
    }
    
    func decrease(product: Product) {
        if let index = items.firstIndex(where: {$0.product.id == product.id}) {
            if items[index].quantity > 1 {
                items[index].quantity -= 1
            } else if items[index].quantity == 1 {
                items.remove(at: index)
            }
        }
    }
    
    func remove(product: Product) {
        if let index = items.firstIndex(where: {$0.product.id == product.id}) {
            items.remove(at: index)
        }
    }
    
    var totalCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    var totalPrice: Int {
        items.reduce(0) { $0 + $1.product.price * $1.quantity}
    }
}
