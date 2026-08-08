//
//  FavoriteService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/31/26.
//

import Foundation
import Observation

@Observable
final class FavoriteService {
    private(set) var favoriteIDs: Set<String> = []
    private(set) var products: [String: Product] = [:]
    
    func contains(productId: String) -> Bool {
        favoriteIDs.contains(productId)
    }
    
    func toggle(product: Product) {
        if favoriteIDs.contains(product.id) {
            favoriteIDs.remove(product.id)
            products[product.id] = nil
        } else {
            favoriteIDs.insert(product.id)
            products[product.id] = product
        }
    }
    
    var items: [Product] {
        favoriteIDs.compactMap { products[$0] }
    }
}
