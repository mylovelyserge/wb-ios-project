//
//  AddressService.swift
//  wb-ios-project
//
//

import Foundation
import Observation

@Observable
final class AddressService {
    var addresses: [DeliveryAddress] = []
    var isLoading = false
    var errorMessage: String?

    private let session = APIClientFactory.makeURLSession()
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    func load() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let request = makeRequest(path: "/addresses", method: "GET")
            let (data, response) = try await session.data(for: request)
            try validate(response)
            addresses = try decoder.decode([AddressResponse].self, from: data).map(\.address)
        } catch {
            errorMessage = "Не удалось загрузить адреса"
            print("Error: \(error)")
        }
    }

    func save(_ address: DeliveryAddress) async -> Bool {
        let isExisting = addresses.contains { $0.id == address.id }
        let path = isExisting ? "/addresses/\(address.id)" : "/addresses"
        let method = isExisting ? "PUT" : "POST"

        do {
            var request = makeRequest(path: path, method: method)
            request.httpBody = try encoder.encode(AddressPayload(address: address))
            let (_, response) = try await session.data(for: request)
            try validate(response)
            await load()
            return true
        } catch {
            errorMessage = "Не удалось сохранить адрес"
            print("Error: \(error)")
            return false
        }
    }

    func delete(_ address: DeliveryAddress) async {
        do {
            let request = makeRequest(path: "/addresses/\(address.id)", method: "DELETE")
            let (_, response) = try await session.data(for: request)
            try validate(response)
            addresses.removeAll { $0.id == address.id }
        } catch {
            errorMessage = "Не удалось удалить адрес"
            print("Error: \(error)")
        }
    }

    private func makeRequest(path: String, method: String) -> URLRequest {
        var request = URLRequest(url: APIClientFactory.baseURL.appending(path: path))
        request.httpMethod = method
        request.setValue("Bearer \(Secrets.apiToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }

    private func validate(_ response: URLResponse) throws {
        guard let response = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        guard (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}

private struct AddressPayload: Codable {
    let addressLine: String
    let coordinates: [Double]
    let floor: String?
    let entrance: String?
    let intercomCode: String?
    let comment: String?

    init(address: DeliveryAddress) {
        addressLine = address.addressLine
        coordinates = address.coordinates
        floor = address.floor.nilIfEmpty
        entrance = address.entrance.nilIfEmpty
        intercomCode = address.intercomCode.nilIfEmpty
        comment = address.comment.nilIfEmpty
    }
}

private struct AddressResponse: Codable {
    let id: String
    let addressLine: String
    let coordinates: [Double]
    let floor: String?
    let entrance: String?
    let intercomCode: String?
    let comment: String?

    var address: DeliveryAddress {
        DeliveryAddress(
            id: id,
            addressLine: addressLine,
            longitude: coordinates.first ?? 0,
            latitude: coordinates.dropFirst().first ?? 0,
            floor: floor ?? "",
            entrance: entrance ?? "",
            intercomCode: intercomCode ?? "",
            comment: comment ?? ""
        )
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
