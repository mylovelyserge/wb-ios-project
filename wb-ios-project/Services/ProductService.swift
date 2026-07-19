//
//  ProductService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/3/26.
//

import Foundation
import OpenAPIURLSession
import Observation

@Observable
final class ProductService {
    var products: [Product] = []
    var isLoading = false
    
    private let client = Client(
        serverURL: URL(string: "https://eat-and-pay.t02.ru")!,
        transport: URLSessionTransport(),
        middlewares: [
            AuthMiddleware(token: Secrets.apiToken),
            LoggingMiddleware()
        ])
    
    func load(categoryId: String) async {
        isLoading = true
        defer {isLoading = false}
        do {
            let response = try await client.get_sol_products(
                query: .init(category: categoryId)
            )
            switch response {
            case .ok(let okResponse):
                let productsDTO = try okResponse.body.json.data
                
                var result: [Product] = []
                for dto in productsDTO {
                    let product = Product(
                        id: dto.id,
                        name: dto.name,
                        imageURL: URL(string: dto.image),
                        price: dto.price,
                        weight: dto.weight,
                        rating: dto.rating,
                        reviewCount: dto.reviewCount
                    )
                    result.append(product)
                }
                self.products = result
                
            case .unauthorized:
                print("401 - No Authorization")
            case .default(statusCode: let statusCode, _):
                print("Unknown status code: \(statusCode)")
            case .badRequest(_):
                print("Bad request")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
