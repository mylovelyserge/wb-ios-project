//
//  FavoritesView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/31/26.
//

import SwiftUI

struct FavoritesView: View {
    @Environment(FavoriteService.self) private var favoriteService
    @Environment(CartService.self) private var cartService
    @State private var selectedProduct: Product? = nil
    @State private var isSearchPresented = false
    
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                Group {
                    if favoriteService.items.isEmpty {
                        ContentUnavailableView("Нет избранного", systemImage: "heart")
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(favoriteService.items) { product in
                                    ProductCard(
                                        product: product,
                                        onAddToCart: { cartService.add(product: product) },
                                        isFavorite: favoriteService.contains(productId: product.id),
                                        onToggleFavorite: { favoriteService.toggle(product: product) }
                                    )
                                    .onTapGesture {
                                        selectedProduct = product
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        
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
