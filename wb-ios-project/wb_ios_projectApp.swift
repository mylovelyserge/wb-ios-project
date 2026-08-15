//
//  wb_ios_projectApp.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 6/30/26.
//

import SwiftUI

@main
struct wb_ios_projectApp: App {
    @State private var cartService = CartService()
    @State private var favoriteService = FavoriteService()
    @State private var categoryService = CategoryService()
    @State private var searchService: SearchService
    
    init() {
        let productService = ProductService()
        let categoryService = CategoryService()
        _categoryService = State(initialValue: categoryService)
        _searchService = State(initialValue: SearchService(
            productService: productService,
            categoryService: categoryService
        ))
    }
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Каталог", systemImage: "list.bullet") {
                    CatalogView()
                }
                
                Tab("Избранное", systemImage: "heart") {
                    FavoritesView()
                }
                
                Tab("Корзина", systemImage: "basket") {
                    CartView()
                }
                .badge(cartService.totalCount)
                
            }
            .environment(cartService)
            .environment(favoriteService)
            .environment(searchService)
            .task { await searchService.loadAllProducts() }
            .environment(categoryService)
        }
    }
}
