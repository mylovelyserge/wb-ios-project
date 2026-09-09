//
//  Order.swift
//  wb-ios-project
//

import Foundation

struct CustomerOrder: Identifiable, Hashable, Sendable {
    let id: String
    let status: OrderStatus
    let deliveryDate: String?
    let address: OrderAddress
    let orderPrice: Int
    let deliveryPrice: Int
    let totalPrice: Int
    let totalItems: Int
    let items: [OrderProduct]

    var etaText: String {
        if let deliveryDate, !deliveryDate.isEmpty {
            return deliveryDate
        }

        switch status {
        case .created:
            return "Заказ принят"
        case .processing, .active:
            return "Готовим заказ"
        case .delivering:
            return "Курьер в пути"
        case .completed:
            return "Доставлен"
        case .canceled:
            return "Отменен"
        case .unknown:
            return "Уточняется"
        }
    }
}

struct OrderProduct: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let imageURL: URL?
    let weight: Int
    let price: Int
    let quantity: Int
}

struct OrderAddress: Hashable, Sendable {
    let addressLine: String
    let floor: String
    let entrance: String
    let intercomCode: String
    let comment: String
}

enum OrderStatus: Hashable, Sendable {
    case created
    case processing
    case delivering
    case completed
    case canceled
    case active
    case unknown(String)

    init(rawValue: String) {
        switch rawValue {
        case "created":
            self = .created
        case "processing":
            self = .processing
        case "delivering":
            self = .delivering
        case "completed":
            self = .completed
        case "canceled", "cancelled":
            self = .canceled
        case "active":
            self = .active
        default:
            self = .unknown(rawValue)
        }
    }

    var title: String {
        switch self {
        case .created:
            return "Создан"
        case .processing, .active:
            return "Готовится"
        case .delivering:
            return "Доставляется"
        case .completed:
            return "Завершен"
        case .canceled:
            return "Отменен"
        case .unknown(let value):
            return value
        }
    }

    var systemImage: String {
        switch self {
        case .created:
            return "doc.badge.plus"
        case .processing, .active:
            return "clock"
        case .delivering:
            return "scooter"
        case .completed:
            return "checkmark.circle.fill"
        case .canceled:
            return "xmark.circle.fill"
        case .unknown:
            return "questionmark.circle"
        }
    }
}
