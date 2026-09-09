//
//  ProductGridView.swift
//  wb-ios-project
//
//

import SwiftUI

struct ProductGridView: View {
    let products: [Product]
    @Binding var selectedProduct: Product?
    @Binding var reviewsProduct: Product?

    @Environment(CartService.self) private var cartService
    @Environment(FavoriteService.self) private var favoriteService

    private let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(products) { product in
                    ProductCard(
                        product: product,
                        onSelect: { selectedProduct = product },
                        onAddToCart: { cartService.add(product: product) },
                        onShowReviews: { reviewsProduct = product },
                        isFavorite: favoriteService.contains(productId: product.id),
                        onToggleFavorite: { favoriteService.toggle(product: product) }
                    )
                }
            }
            .padding(.horizontal, 12)
        }
        .task(id: products.map(\.id)) {
            await RemoteImageCache.shared.prefetch(products.compactMap(\.imageURL))
        }
    }
}

#Preview {
    @Previewable @State var selectedProduct: Product?
    @Previewable @State var reviewsProduct: Product?

    ProductGridView(
        products: Product.mocks,
        selectedProduct: $selectedProduct,
        reviewsProduct: $reviewsProduct
    )
        .environment(CartService())
        .environment(FavoriteService())
}
