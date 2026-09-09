//
//  OrderService.swift
//  wb-ios-project
//

import Foundation
import Observation

@MainActor
@Observable
final class OrderService {
    var orders: [CustomerOrder] = []
    var isLoading = false
    var isSubmitting = false
    var errorMessage: String?

    private let client = APIClientFactory.makeClient()

    func loadOrders() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response = try await client.get_sol_orders()
            switch response {
            case .ok(let okResponse):
                let payload = try okResponse.body.json
                orders = payload.map(mapOrder)
            case .unauthorized:
                errorMessage = "Не удалось авторизоваться"
            case .default:
                errorMessage = "Не удалось загрузить заказы"
            }
        } catch {
            errorMessage = "Не удалось загрузить заказы"
            print("Error: \(error)")
        }
    }

    func createOrder(addressID: String, paymentMethod: String = "card") async -> Bool {
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let response = try await client.post_sol_orders(
                body: .json(.init(
                    paymentMethod: paymentMethod,
                    addressID: addressID
                ))
            )

            switch response {
            case .ok:
                await loadOrders()
                return true
            case .badRequest:
                errorMessage = "Проверьте данные заказа"
            case .unauthorized:
                errorMessage = "Не удалось авторизоваться"
            case .default:
                errorMessage = "Не удалось оформить заказ"
            }
        } catch {
            errorMessage = "Не удалось оформить заказ"
            print("Error: \(error)")
        }

        return false
    }

    private func mapOrder(_ dto: Components.Schemas.Order) -> CustomerOrder {
        CustomerOrder(
            id: dto.id,
            status: OrderStatus(rawValue: dto.status.rawValue),
            deliveryDate: dto.deliveryDate,
            address: mapAddress(dto.address),
            orderPrice: dto.orderPrice,
            deliveryPrice: dto.deliveryPrice,
            totalPrice: dto.totalPrice,
            totalItems: dto.totalItems,
            items: dto.items.map(mapItem)
        )
    }

    private func mapItem(_ dto: Components.Schemas.OrderItem) -> OrderProduct {
        OrderProduct(
            id: dto.id,
            name: dto.name,
            imageURL: URL(string: dto.image),
            weight: dto.weight,
            price: dto.price,
            quantity: dto.quantity
        )
    }

    private func mapAddress(_ dto: Components.Schemas.Address) -> OrderAddress {
        OrderAddress(
            addressLine: dto.addressLine,
            floor: dto.floor ?? "",
            entrance: dto.entrance ?? "",
            intercomCode: dto.intercomCode ?? "",
            comment: dto.comment ?? ""
        )
    }
}
