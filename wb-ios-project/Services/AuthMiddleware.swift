//
//  AuthMiddleware.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/1/26.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

struct AuthMiddleware: ClientMiddleware {
    let token: String
    
    func intercept(_ request: HTTPRequest,
                   body: HTTPBody?, baseURL: URL,
                   operationID: String,
                   next: @concurrent (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    )async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        request.headerFields[.authorization] = "Bearer \(token)"
        return try await next(request, body, baseURL)
    }
}
