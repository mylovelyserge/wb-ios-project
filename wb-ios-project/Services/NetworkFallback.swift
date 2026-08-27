//
//  NetworkFallback.swift
//  wb-ios-project
//
//

import Foundation

enum NetworkFallback {
    static let usesMockDataOnTransportFailure = true

    static func message(_ originalMessage: String) -> String {
        "\(originalMessage). Показаны тестовые данные."
    }
}
