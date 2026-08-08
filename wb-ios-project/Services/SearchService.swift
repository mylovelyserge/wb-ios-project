//
//  SearchService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 8/5/26.
//

import Foundation
import OpenAPIURLSession
import Observation

@Observable
final class SearchService {
    private(set) var allProducts: [Product] = []
    private(set) var history: [String] = []
    private let productService: ProductService
    private let categoryService: CategoryService
    
    init(productService: ProductService, categoryService: CategoryService) {
        self.productService = productService
        self.categoryService = categoryService
    }
    
    func loadAllProducts() async {
        guard allProducts.isEmpty else { return }

        await categoryService.load()
        let categories = categoryService.categories

        let collected = await withTaskGroup(of: [Product].self) { group in
            for category in categories {
                group.addTask { [productService] in
                    do {
                        return try await productService.fetch(categoryId: category.id)
                    } catch {
                        return []
                    }
                }
            }

            var result: [Product] = []
            for await products in group {
                result.append(contentsOf: products)
            }
            return result
        }

        var seen = Set<String>()
        let unique = collected.filter { seen.insert($0.id).inserted }
        allProducts = unique
    }
    
    func search(_ query: String) -> [Product] {
        guard !query.isEmpty else { return [] }
        return allProducts.filter {
            $0.name.localizedCaseInsensitiveContains(query)
        }
    }
    
    func addToHistory(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        history.removeAll { $0.localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
        history.insert(trimmed, at: 0)
        if history.count > 10 {
            history.removeLast()
        }
    }
}
