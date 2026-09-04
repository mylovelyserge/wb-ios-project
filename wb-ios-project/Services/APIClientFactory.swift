//
//  APIClientFactory.swift
//  wb-ios-project
//
//

import Foundation
import OpenAPIURLSession

enum APIClientFactory {
    static let baseURL = URL(string: "https://eat-and-pay.t02.ru")!

    static func makeURLSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60

        return URLSession(
            configuration: configuration,
            delegate: T02ServerTrustDelegate(),
            delegateQueue: nil
        )
    }

    static func makeClient() -> Client {
        return Client(
            serverURL: baseURL,
            transport: URLSessionTransport(configuration: .init(session: makeURLSession())),
            middlewares: [
                AuthMiddleware(token: Secrets.apiToken),
                LoggingMiddleware()
            ]
        )
    }
}
