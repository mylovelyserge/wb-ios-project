//
//  CategoryService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/1/26.
//

import Foundation
import Observation

@Observable
final class CategoryService {
    var categories: [Category] = []
    private let client = APIClientFactory.makeClient()
    
    func load() async {
        guard categories.isEmpty else { return }
        do {
            let response = try await client.get_sol_categories()
            switch response {
            case .ok(let okResponse):
                let categoriesDTO = try okResponse.body.json

                categories = categoriesDTO.map { dto in
                    Category(
                        id: dto.id,
                        name: dto.name,
                        imageURL: URL(string: dto.image)
                    )
                }
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
