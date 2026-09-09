//
//  CartService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/12/26.
//

import Foundation
import Observation

@MainActor
@Observable
final class CartService {
    private(set) var quantities: [String: Int] = [:]
    private(set) var products: [String: Product] = [:]
    var isSyncing = false
    var errorMessage: String?

    private let client = APIClientFactory.makeClient()
    private let store = CartStore()

    init() {
        Task { await refreshFromStore() }
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
                let snapshotItems = payload.items.map { item in
                    let dto = item.value1
                    return CartStore.ItemSnapshot(
                        product: Product(
                            id: dto.id,
                            name: dto.name,
                            imageURL: URL(string: dto.image),
                            price: dto.price,
                            weight: Double(dto.weight),
                            rating: 0,
                            reviewCount: 0
                        ),
                        quantity: dto.quantity
                    )
                }
                let snapshot = await store.replace(with: snapshotItems)
                apply(snapshot)
            case .unauthorized:
                errorMessage = "Не удалось авторизоваться"
            case .default:
                errorMessage = "Не удалось загрузить корзину"
            }
        } catch {
            errorMessage = "Корзина загружена из локального сохранения"
            await refreshFromStore()
            print("Error: \(error)")
        }
    }

    func add(product: Product) {
        Task {
            let snapshot = await store.add(product: product)
            apply(snapshot)
            await addRemote(productId: product.id)
        }
    }

    func increase(productId: String) {
        Task {
            let snapshot = await store.increase(productId: productId)
            apply(snapshot)
            await addRemote(productId: productId)
        }
    }

    func decrease(productId: String) {
        Task {
            let snapshot = await store.decrease(productId: productId)
            apply(snapshot)
            await deleteRemote(productId: productId)
        }
    }

    func remove(productId: String) {
        Task {
            let snapshot = await store.remove(productId: productId)
            apply(snapshot)
            await deleteRemote(productId: productId)
        }
    }

    func clear() {
        Task {
            let snapshot = await store.clear()
            apply(snapshot)
        }
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

    private func refreshFromStore() async {
        let snapshot = await store.snapshot()
        apply(snapshot)
    }

    private func apply(_ snapshot: CartStore.Snapshot) {
        products = snapshot.products
        quantities = snapshot.quantities
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
}

actor CartStore {
    struct Snapshot: Sendable {
        let products: [String: Product]
        let quantities: [String: Int]
    }

    struct ItemSnapshot: Sendable {
        let product: Product
        let quantity: Int
    }

    private var quantities: [String: Int] = [:]
    private var products: [String: Product] = [:]
    private let storageKey = "cart.items.v1"

    init() {
        let restoredItems = Self.restoreLocalCart(storageKey: storageKey)
        products = Dictionary(uniqueKeysWithValues: restoredItems.map { ($0.product.id, $0.product) })
        quantities = Dictionary(uniqueKeysWithValues: restoredItems.map { ($0.product.id, $0.quantity) })
    }

    func snapshot() -> Snapshot {
        Snapshot(products: products, quantities: quantities)
    }

    func replace(with items: [ItemSnapshot]) -> Snapshot {
        products = Dictionary(uniqueKeysWithValues: items.map { ($0.product.id, $0.product) })
        quantities = Dictionary(uniqueKeysWithValues: items.map { ($0.product.id, $0.quantity) })
        persistLocalCart()
        return snapshot()
    }

    func add(product: Product) -> Snapshot {
        quantities[product.id, default: 0] += 1
        products[product.id] = product
        persistLocalCart()
        return snapshot()
    }

    func increase(productId: String) -> Snapshot {
        quantities[productId, default: 0] += 1
        persistLocalCart()
        return snapshot()
    }

    func decrease(productId: String) -> Snapshot {
        guard let current = quantities[productId] else { return snapshot() }
        if current > 1 {
            quantities[productId] = current - 1
        } else {
            quantities[productId] = nil
            products[productId] = nil
        }
        persistLocalCart()
        return snapshot()
    }

    func remove(productId: String) -> Snapshot {
        quantities[productId] = nil
        products[productId] = nil
        persistLocalCart()
        return snapshot()
    }

    func clear() -> Snapshot {
        quantities.removeAll()
        products.removeAll()
        persistLocalCart()
        return snapshot()
    }

    private static func restoreLocalCart(storageKey: String) -> [StoredCartItem] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return [] }
        do {
            return try JSONDecoder().decode([StoredCartItem].self, from: data)
        } catch {
            UserDefaults.standard.removeObject(forKey: storageKey)
            return []
        }
    }

    private func persistLocalCart() {
        let snapshot = quantities.sorted { $0.key < $1.key }.compactMap { pair -> StoredCartItem? in
            guard let product = products[pair.key] else { return nil }
            return StoredCartItem(product: product, quantity: pair.value)
        }
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}

private struct StoredCartItem: Codable, Sendable {
    let product: Product
    let quantity: Int
}
