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
    @State private var isSplashVisible = true
    
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
            ZStack {
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

                    Tab("Профиль", systemImage: "person") {
                        ProfileView()
                    }
                }
                .environment(cartService)
                .environment(favoriteService)
                .environment(searchService)
                .environment(categoryService)

                if isSplashVisible {
                    SplashView()
                        .transition(.opacity)
                }
            }
            .task {
                try? await Task.sleep(for: .seconds(1.1))
                withAnimation(.easeOut(duration: 0.35)) {
                    isSplashVisible = false
                }
            }
        }
    }
}
