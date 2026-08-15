//
//  FavoritesView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/31/26.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(FavoriteService.self) private var favoriteService
    @State private var selectedProduct: Product? = nil
    @State private var isSearchPresented = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if favoriteService.items.isEmpty {
                        ContentUnavailableView("Нет избранного", systemImage: "heart")
                    } else {
                        ProductGridView(products: favoriteService.items, selectedProduct: $selectedProduct)
                    }
                }
                .navigationTitle("Избранное")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(item: $selectedProduct) { product in
                    ProductDetailView(productId: product.id)
                }
                .fullScreenCover(isPresented: $isSearchPresented) {
                    SearchView()
                }
                
                SearchButton {
                    isSearchPresented = true
                }
                .padding(12)
            }
        }
    }
}

#Preview {
    let favorites = FavoriteService()
    favorites.toggle(product: Product.mocks[0])
    favorites.toggle(product: Product.mocks[1])
    return FavoritesView()
        .environment(favorites)
        .environment(CartService())
        .environment(SearchService(productService: ProductService(), categoryService: CategoryService()))
}
