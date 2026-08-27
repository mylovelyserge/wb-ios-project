//
//  APIClientFactory.swift
//  wb-ios-project
//
//

import Foundation
import OpenAPIURLSession

enum APIClientFactory {
    static func makeClient() -> Client {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        let session = URLSession(
            configuration: configuration,
            delegate: T02ServerTrustDelegate(),
            delegateQueue: nil
        )

        return Client(
            serverURL: URL(string: "https://eat-and-pay.t02.ru")!,
            transport: URLSessionTransport(configuration: .init(session: session)),
            middlewares: [
                AuthMiddleware(token: Secrets.apiToken),
                LoggingMiddleware()
            ]
        )
    }
}
