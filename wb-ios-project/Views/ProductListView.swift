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
    
    let columns = [
        GridItem(.flexible(), spacing: 4),
        GridItem(.flexible(), spacing: 4),
    ]
    var body: some View {
        Group {
            if service.isLoading {
                ProgressView()
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(service.products) { product in
                            ProductCard(product: product)
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }
        }
        .task {
            await service.load(categoryId: categoryID)
        }
    }
}

#Preview {
    ProductListView(categoryID: "1")
}
