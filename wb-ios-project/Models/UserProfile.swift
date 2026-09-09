//
//  UserProfile.swift
//  wb-ios-project
//

import Foundation

struct UserProfile: Codable, Hashable, Sendable {
    var name: String
    var phone: String
    var birthday: String
    var imageURL: URL?

    static let empty = UserProfile(
        name: "",
        phone: "",
        birthday: "",
        imageURL: nil
    )
}
