//
//  ProductService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/3/26.
//

import Foundation
import Observation

enum ProductServiceError: Error {
    case unauthorized
    case badRequest
    case unexpected(Int)
}

@Observable
final class ProductService {
    var products: [Product] = []
    var isLoading = false
    
    private let client = APIClientFactory.makeClient()
    
    func load(categoryId: String) async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await fetch(categoryId: categoryId)
        } catch {
            print("Error: \(error)")
        }
    }
    
    func fetch(categoryId: String) async throws -> [Product] {
        let response = try await client.get_sol_products(
            query: .init(category: categoryId)
        )
        switch response {
        case .ok(let okResponse):
            let productsDTO = try okResponse.body.json.data
            return productsDTO.map { dto in
                Product(
                    id: dto.id,
                    name: dto.name,
                    imageURL: URL(string: dto.image),
                    price: dto.price,
                    weight: dto.weight,
                    rating: dto.rating,
                    reviewCount: dto.reviewCount
                )
            }
        case .unauthorized:
            throw ProductServiceError.unauthorized
        case .badRequest:
            throw ProductServiceError.badRequest
        case .default(let statusCode, _):
            throw ProductServiceError.unexpected(statusCode)
        }
    }
}
