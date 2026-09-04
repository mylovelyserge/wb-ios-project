//
//  DeliveryAddress.swift
//  wb-ios-project
//
//

import Foundation

struct DeliveryAddress: Identifiable, Codable, Hashable {
    var id: String
    var addressLine: String
    var longitude: Double
    var latitude: Double
    var floor: String
    var entrance: String
    var intercomCode: String
    var comment: String

    var coordinates: [Double] {
        [longitude, latitude]
    }

    static let empty = DeliveryAddress(
        id: UUID().uuidString,
        addressLine: "",
        longitude: 37.6173,
        latitude: 55.7558,
        floor: "",
        entrance: "",
        intercomCode: "",
        comment: ""
    )
}
