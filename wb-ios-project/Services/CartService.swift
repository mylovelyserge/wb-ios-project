//
//  CartService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/12/26.
//

import Foundation
import Observation

@Observable
final class CartService {
    private(set) var quantities: [String: Int] = [:]
    private(set) var products: [String: Product] = [:]
    var isSyncing = false
    var errorMessage: String?

    private let client = APIClientFactory.makeClient()
    private let storageKey = "cart.items.v1"

    init() {
        restoreLocalCart()
    }

    func load() async {
        guard !isSyncing else { return }

        isSyncing = true
        errorMessage = nil
        defer { isSyncing = false }

        do {
            let response = try await client.get_sol_cart()
            switch response {
            case .ok(let okResponse):
                let payload = try okResponse.body.json
                var loadedProducts: [String: Product] = [:]
                var loadedQuantities: [String: Int] = [:]

                for item in payload.items {
                    let dto = item.value1
                    loadedProducts[dto.id] = Product(
                        id: dto.id,
                        name: dto.name,
                        imageURL: URL(string: dto.image),
                        price: dto.price,
                        weight: Double(dto.weight),
                        rating: 0,
                        reviewCount: 0
                    )
                    loadedQuantities[dto.id] = dto.quantity
                }

                products = loadedProducts
                quantities = loadedQuantities
                persistLocalCart()
            case .unauthorized:
                errorMessage = "Не удалось авторизоваться"
            case .default:
                errorMessage = "Не удалось загрузить корзину"
            }
        } catch {
            errorMessage = "Корзина загружена из локального сохранения"
            print("Error: \(error)")
        }
    }

    func add(product: Product) {
        quantities[product.id, default: 0] += 1
        products[product.id] = product
        persistLocalCart()
        Task { await addRemote(productId: product.id) }
    }

    func increase(productId: String) {
        quantities[productId, default: 0] += 1
        persistLocalCart()
        Task { await addRemote(productId: productId) }
    }

    func decrease(productId: String) {
        guard let current = quantities[productId] else { return }
        if current > 1 {
            quantities[productId] = current - 1
        } else {
            quantities[productId] = nil
            products[productId] = nil
        }
        persistLocalCart()
        Task { await deleteRemote(productId: productId) }
    }

    func remove(productId: String) {
        quantities[productId] = nil
        products[productId] = nil
        persistLocalCart()
        Task { await deleteRemote(productId: productId) }
    }

    func clear() {
        quantities.removeAll()
        products.removeAll()
        persistLocalCart()
    }

    var totalCount: Int {
        quantities.values.reduce(0, +)
    }

    var totalPrice: Int {
        quantities.reduce(0) { sum, pair in
            let price = products[pair.key]?.price ?? 0
            return sum + price * pair.value
        }
    }

    var items: [CartItem] {
        quantities.sorted { $0.key < $1.key }.compactMap { pair in
            guard let product = products[pair.key] else { return nil }
            return CartItem(product: product, quantity: pair.value)
        }
    }

    private func addRemote(productId: String) async {
        do {
            let response = try await client.post_sol_cart_sol_items(query: .init(id: productId))
            if case .unauthorized = response {
                errorMessage = "Не удалось авторизоваться"
            }
        } catch {
            errorMessage = "Корзина сохранена локально, синхронизация не выполнена"
            print("Error: \(error)")
        }
    }

    private func deleteRemote(productId: String) async {
        do {
            let response = try await client.delete_sol_cart_sol_items_sol__lcub_id_rcub_(path: .init(id: productId))
            if case .unauthorized = response {
                errorMessage = "Не удалось авторизоваться"
            }
        } catch {
            errorMessage = "Корзина сохранена локально, синхронизация не выполнена"
            print("Error: \(error)")
        }
    }

    private func restoreLocalCart() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        do {
            let snapshot = try JSONDecoder().decode([StoredCartItem].self, from: data)
            products = Dictionary(uniqueKeysWithValues: snapshot.map { ($0.product.id, $0.product) })
            quantities = Dictionary(uniqueKeysWithValues: snapshot.map { ($0.product.id, $0.quantity) })
        } catch {
            UserDefaults.standard.removeObject(forKey: storageKey)
        }
    }

    private func persistLocalCart() {
        let snapshot = items.map { StoredCartItem(product: $0.product, quantity: $0.quantity) }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

private struct StoredCartItem: Codable {
    let product: Product
    let quantity: Int
}
