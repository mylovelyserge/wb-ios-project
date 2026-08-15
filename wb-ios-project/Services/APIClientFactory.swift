//
//  APIClientFactory.swift
//  wb-ios-project
//
//  Created by Codex on 8/15/26.
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
