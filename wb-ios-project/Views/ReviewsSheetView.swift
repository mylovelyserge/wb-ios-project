//
//  ReviewsSheetView.swift
//  wb-ios-project
//
//

import SwiftUI

struct ReviewsSheetView: View {
    let productId: String
    @State private var service = ProductDetailService()

    var body: some View {
        NavigationStack {
            Group {
                if service.isLoading {
                    ProgressView()
                } else if let errorMessage = service.errorMessage {
                    LoadingErrorView(
                        title: "Не удалось загрузить отзывы",
                        message: errorMessage,
                        retryTitle: "Повторить",
                        onRetry: {
                            Task { await service.load(productId: productId) }
                        }
                    )
                } else if let product = service.product {
                    ScrollView {
                        ReviewsSectionView(
                            reviews: product.reviews,
                            isSubmitting: service.isSubmittingReview,
                            errorMessage: service.reviewErrorMessage,
                            onSubmit: { rating, content in
                                await service.submitReview(
                                    productId: product.id,
                                    rating: rating,
                                    content: content
                                )
                            }
                        )
                        .padding(16)
                    }
                } else {
                    ContentUnavailableView("Отзывы не найдены", systemImage: "text.bubble")
                }
            }
            .navigationTitle("Отзывы")
            .navigationBarTitleDisplayMode(.inline)
            .task(id: productId) {
                await service.load(productId: productId)
            }
        }
    }
}

#Preview {
    ReviewsSheetView(productId: "1")
}
