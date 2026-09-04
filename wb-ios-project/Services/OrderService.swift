//
//  OrderService.swift
//  wb-ios-project
//
//

import Foundation
import Observation

@Observable
final class OrderService {
    var isSubmitting = false
    var errorMessage: String?

    private let client = APIClientFactory.makeClient()

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
}
