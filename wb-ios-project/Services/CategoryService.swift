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
    var isLoading = false
    var errorMessage: String?
    private let client = APIClientFactory.makeClient()
    
    func load(forceReload: Bool = false) async {
        guard !isLoading else { return }
        guard forceReload || categories.isEmpty else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

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
                errorMessage = "Не удалось авторизоваться"
            case .default(statusCode: let statusCode, _):
                errorMessage = "Сервер вернул ошибку \(statusCode)"
                print("Unknown status code: \(statusCode)")
            }
        } catch {
            if NetworkFallback.usesMockDataOnTransportFailure {
                categories = Category.mocks
                errorMessage = nil
            } else {
                errorMessage = "Не удалось подключиться к серверу"
            }
            print("Error: \(error)")
        }
    }
}
