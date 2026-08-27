//
//  ProductDetailService.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/7/26.
//

import Foundation
import Observation

@Observable
final class ProductDetailService {
    var product: ProductDetail?
    var isLoading = false
    var errorMessage: String?
    var isSubmittingReview = false
    var reviewErrorMessage: String?
    
    private let client = APIClientFactory.makeClient()
    
    func load(productId: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            let response = try await client.get_sol_products_sol__lcub_id_rcub_(
                path: .init(id: productId)
            )
            switch response {
            case .ok(let okResponse):
                let dto = try okResponse.body.json
                let reviews = dto.reviews?.map { review in
                    Review(
                        rating: review.rating,
                        author: review.author,
                        createdAt: review.createdAt,
                        content: review.content,
                        imageURLs: review.images.compactMap(URL.init(string:))
                    )
                } ?? []

                product = ProductDetail(
                    id: dto.id,
                    name: dto.name,
                    imageURL: URL(string: dto.image),
                    price: dto.price,
                    weight: dto.weight,
                    rating: dto.rating,
                    description: dto.description,
                    reviews: reviews,
                    reviewsCount: reviews.count,
                    isFavorite: dto.isFavorite
                )
                
            case .unauthorized:
                errorMessage = "Не удалось авторизоваться"
                print("401 - No Authorization")
            case .notFound(_):
                errorMessage = "Товар не найден"
                print("Not found")
            case .default(statusCode: let statusCode, _):
                errorMessage = "Сервер вернул ошибку \(statusCode)"
                print("Unknown status code: \(statusCode)")
            }
        } catch {
            if NetworkFallback.usesMockDataOnTransportFailure {
                product = ProductDetail.mock(for: productId)
                errorMessage = nil
            } else {
                errorMessage = "Не удалось подключиться к серверу"
            }
            print("Error: \(error)")
        }
    }

    func submitReview(productId: String, rating: Int, content: String) async -> Bool {
        let trimmedContent = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else { return false }

        isSubmittingReview = true
        reviewErrorMessage = nil
        defer { isSubmittingReview = false }

        do {
            let response = try await client.post_sol_products_sol__lcub_id_rcub__sol_reviews(
                path: .init(id: productId),
                body: .json(.init(
                    rating: rating,
                    content: trimmedContent,
                    images: []
                ))
            )

            switch response {
            case .ok:
                await load(productId: productId)
                return true
            case .badRequest:
                reviewErrorMessage = "Проверьте оценку и текст отзыва"
            case .unauthorized:
                reviewErrorMessage = "Не удалось авторизоваться"
            case .default:
                reviewErrorMessage = "Не удалось отправить отзыв"
            }
        } catch {
            reviewErrorMessage = "Не удалось отправить отзыв"
            print("Error: \(error)")
        }

        return false
    }
}
