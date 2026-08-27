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

extension ProductServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Не удалось авторизоваться"
        case .badRequest:
            return "Сервер не принял запрос товаров"
        case .unexpected(let statusCode):
            return "Сервер вернул ошибку \(statusCode)"
        }
    }
}

@Observable
final class ProductService {
    var products: [Product] = []
    var isLoading = false
    var errorMessage: String?
    
    private let client = APIClientFactory.makeClient()
    
    func load(categoryId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            products = try await fetch(categoryId: categoryId)
        } catch {
            if NetworkFallback.usesMockDataOnTransportFailure {
                products = Product.mocks
                errorMessage = nil
            } else {
                errorMessage = error.localizedDescription
            }
            print("Error: \(error)")
        }
    }
    
    func fetch(categoryId: String) async throws -> [Product] {
        let response: Operations.get_sol_products.Output
        do {
            response = try await client.get_sol_products(
                query: .init(category: categoryId)
            )
        } catch {
            if NetworkFallback.usesMockDataOnTransportFailure {
                return Product.mocks
            }
            throw error
        }

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
