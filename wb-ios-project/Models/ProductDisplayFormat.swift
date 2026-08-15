//
//  ProductDisplayFormat.swift
//  wb-ios-project
//
//

import Foundation

enum ProductDisplayFormat {
    static func price(_ value: Int) -> String {
        "\(value) ₽"
    }

    static func totalPrice(_ value: Int) -> String {
        "Итого: \(price(value))"
    }

    static func weight(_ value: Double) -> String {
        "\(Int(value)) г"
    }

    static func rating(_ value: Float) -> String {
        String(format: "%.1f", value)
    }

    static func reviews(_ count: Int) -> String {
        "\(count) \(reviewsWord(for: count))"
    }

    private static func reviewsWord(for count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = lastTwoDigits % 10

        if (11...14).contains(lastTwoDigits) {
            return "отзывов"
        }

        switch lastDigit {
        case 1:
            return "отзыв"
        case 2...4:
            return "отзыва"
        default:
            return "отзывов"
        }
    }
}
