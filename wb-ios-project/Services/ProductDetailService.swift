//
//  ProductDetailService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/7/26.
//

import Foundation
import OpenAPIURLSession
import Observation

@Observable
final class ProductDetailService {
    var product: ProductDetail?
    var isLoading = false
    
    private let client = Client(
        serverURL: URL(string: "https://eat-and-pay.t02.ru")!,
        transport: URLSessionTransport(),
        middlewares: [
            AuthMiddleware(token: Secrets.apiToken),
            LoggingMiddleware()
        ])
    
    func load(productId: String) async {
        isLoading = true
        defer {isLoading = false}
        
        do {
            let response = try await client.get_sol_products_sol__lcub_id_rcub_(
                path: .init(id: productId)
            )
            switch response {
            case .ok(let okRresponse):
                let dto = try okRresponse.body.json
                self.product = ProductDetail(
                    id: dto.id,
                    name: dto.name,
                    imageURL: URL(string: dto.image),
                    price: dto.price,
                    weight: dto.weight,
                    rating: dto.rating,
                    description: dto.description,
                    reviewsCount: dto.reviews?.count ?? 0,
                    isFavorite: dto.isFavorite
                )
                
            case .unauthorized:
                print("401 - No Authorization")
            case .notFound(_):
                print("Not found")
            case .default(statusCode: let statusCode, _):
                print("Unknown status code: \(statusCode)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
