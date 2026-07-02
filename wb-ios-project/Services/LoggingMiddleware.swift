//
//  LoggingMiddleware.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/2/26.
//

import Foundation
import OpenAPIRuntime
import HTTPTypes

struct LoggingMiddleware: ClientMiddleware {
    func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?, baseURL: URL,
        operationID: String,
        next: @concurrent (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        
        print("\(request.method.rawValue) \(request.path ?? "")")
        
        let (response, responseBody) = try await next(request, body, baseURL)
        
        print("\(response.status.code) \(request.path ?? "")")
        
        return (response, responseBody)
    }
}
