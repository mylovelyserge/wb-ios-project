//
//  ProfileService.swift
//  wb-ios-project
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileService {
    var profile: UserProfile?
    var isLoading = false
    var isSaving = false
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
            let request = makeRequest(path: "/users/me", method: "GET")
            let (data, response) = try await session.data(for: request)
            try validate(response)
            profile = try decoder.decode(ProfileResponse.self, from: data).profile
        } catch {
            errorMessage = "Не удалось загрузить профиль"
            print("Error: \(error)")
        }
    }

    func save(_ profile: UserProfile) async -> Bool {
        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            var request = makeRequest(path: "/users/me", method: "PUT")
            request.httpBody = try encoder.encode(ProfilePayload(profile: profile))
            let (_, response) = try await session.data(for: request)
            try validate(response)
            self.profile = profile
            return true
        } catch {
            errorMessage = "Не удалось сохранить профиль"
            print("Error: \(error)")
            return false
        }
    }

    func logout() async -> Bool {
        do {
            let request = makeRequest(path: "/logout", method: "POST")
            let (_, response) = try await session.data(for: request)
            try validate(response)
            return true
        } catch {
            errorMessage = "Не удалось выйти из профиля"
            print("Error: \(error)")
            return false
        }
    }

    func deleteProfile() async -> Bool {
        do {
            let request = makeRequest(path: "/users/me", method: "DELETE")
            let (_, response) = try await session.data(for: request)
            try validate(response)
            await load()
            return true
        } catch {
            errorMessage = "Не удалось удалить профиль"
            print("Error: \(error)")
            return false
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

private struct ProfileResponse: Codable {
    let name: String
    let phone: String
    let birthday: String
    let imageUrl: String?

    var profile: UserProfile {
        UserProfile(
            name: name,
            phone: phone,
            birthday: birthday,
            imageURL: imageUrl.flatMap(URL.init(string:))
        )
    }
}

private struct ProfilePayload: Codable {
    let name: String
    let birthday: String
    let imageUri: String

    init(profile: UserProfile) {
        name = profile.name
        birthday = profile.birthday
        imageUri = profile.imageURL?.absoluteString ?? ""
    }
}
