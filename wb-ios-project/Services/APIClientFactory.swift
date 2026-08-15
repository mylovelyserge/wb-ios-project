//
//  APIClientFactory.swift
//  wb-ios-project
//
//

import Foundation
import OpenAPIURLSession

enum APIClientFactory {
    static func makeClient() -> Client {
        Client(
            serverURL: URL(string: "https://eat-and-pay.t02.ru")!,
            transport: URLSessionTransport(),
            middlewares: [
                AuthMiddleware(token: Secrets.apiToken),
                LoggingMiddleware()
            ]
        )
    }
}
