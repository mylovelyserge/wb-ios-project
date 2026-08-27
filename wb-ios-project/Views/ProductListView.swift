//
//  ProductListView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/2/26.
//

import SwiftUI

struct ProductListView: View {
    let categoryID: String
    @State private var service = ProductService()
    @State private var selectedProduct: Product? = nil
    @State private var reviewsProduct: Product? = nil

    var body: some View {
        Group {
            if service.isLoading {
                ProgressView()
            } else if let errorMessage = service.errorMessage {
                LoadingErrorView(
                    title: "Не удалось загрузить товары",
                    message: errorMessage,
                    retryTitle: "Повторить",
                    onRetry: {
                        Task { await service.load(categoryId: categoryID) }
                    }
                )
            } else if service.products.isEmpty {
                ContentUnavailableView("Товаров нет", systemImage: "takeoutbag.and.cup.and.straw")
            } else {
                ProductGridView(
                    products: service.products,
                    selectedProduct: $selectedProduct,
                    reviewsProduct: $reviewsProduct
                )
            }
        }
        .task(id: categoryID) {
            await service.load(categoryId: categoryID)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(productId: product.id)
        }
        .sheet(item: $reviewsProduct) { product in
            ReviewsSheetView(productId: product.id)
        }
    }
}

#Preview {
    ProductListView(categoryID: "1")
        .environment(CartService())
        .environment(FavoriteService())
}
