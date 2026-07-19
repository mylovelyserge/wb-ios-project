//
//  CarItem+Mock.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/12/26.
//

import Foundation

extension CartItem {
    static let mocks: [CartItem] = [
        CartItem(product: Product.mocks[0], quantity: 2),
        CartItem(product: Product.mocks[1], quantity: 1),
        CartItem(product: Product.mocks[2], quantity: 3),
        CartItem(product: Product.mocks[3], quantity: 2),
    ]
        
}
