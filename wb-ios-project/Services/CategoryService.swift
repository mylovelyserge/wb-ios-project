//
//  CategoryService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/1/26.
//

import Foundation
import OpenAPIURLSession
import Observation

@Observable
final class CategoryService {
    var categories: [Category] = []
    private let client = Client(
        serverURL: URL(string: "https://eat-and-pay.t02.ru")!,
        transport: URLSessionTransport(),
        middlewares: [AuthMiddleware(token: Secrets.apiToken)])
    
    func load() async {
        do {
            let response = try await client.get_sol_categories()
            switch response {
            case .ok(let okResponse):
                let categoriesDTO = try okResponse.body.json
                
                var result: [Category] = []
                for dto in categoriesDTO {
                    let category = Category(
                        id: dto.id,
                        name: dto.name,
                        imageURL: URL(string: dto.image))
                    result.append(category)
                }
                self.categories = result
            case .unauthorized:
                print("401 - No Authorization")
            case .default(statusCode: let statusCode, _):
                print("Unknown status code: \(statusCode)")
            }
        } catch {
            print("Error: \(error)")
        }
    }
}
