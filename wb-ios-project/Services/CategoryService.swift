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
        transport: URLSessionTransport())
    
    func load() async {
        do {
            let response = try await client.get_sol_categories()
            switch response {
            case .ok(let okResponse):
                let categoriesDTO = try okResponse.body.json
                print("Categories: \(categoriesDTO.count)")
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
