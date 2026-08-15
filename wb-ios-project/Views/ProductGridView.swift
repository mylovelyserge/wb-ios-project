//
//  ProductGridView.swift
//  wb-ios-project
//
//  Created by Codex on 8/15/26.
//

import SwiftUI

struct ProductGridView: View {
    let products: [Product]
    @Binding var selectedProduct: Product?

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
                        onAddToCart: { cartService.add(product: product) },
                        isFavorite: favoriteService.contains(productId: product.id),
                        onToggleFavorite: { favoriteService.toggle(product: product) }
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedProduct = product
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

#Preview {
    @Previewable @State var selectedProduct: Product?

    ProductGridView(products: Product.mocks, selectedProduct: $selectedProduct)
        .environment(CartService())
        .environment(FavoriteService())
}
