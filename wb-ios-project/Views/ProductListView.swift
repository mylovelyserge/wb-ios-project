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

    var body: some View {
        Group {
            if service.isLoading {
                ProgressView()
            } else {
                ProductGridView(products: service.products, selectedProduct: $selectedProduct)
            }
        }
        .task(id: categoryID) {
            await service.load(categoryId: categoryID)
        }
        .sheet(item: $selectedProduct) { product in
            ProductDetailView(productId: product.id)
        }
    }
}

#Preview {
    ProductListView(categoryID: "1")
        .environment(CartService())
        .environment(FavoriteService())
}
