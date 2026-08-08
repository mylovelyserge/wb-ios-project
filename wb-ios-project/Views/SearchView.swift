//
//  SearchView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 8/5/26.
//

import SwiftUI

struct SearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SearchService.self) private var searchService
    @Environment(CartService.self) private var cartService
    @Environment(FavoriteService.self) private var favoriteService
    
    @State private var query = ""
    @State private var results: [Product] = []
    @FocusState private var isFocused: Bool
    @State private var searchTask: Task<Void, Never>?
    @State private var selectedProduct: Product?
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Group {
                    if query.isEmpty {
                        List(searchService.history, id: \.self) { item in
                            Button {
                                query = item
                            } label: {
                                Text(item)
                                    .foregroundStyle(.primary)
                            }
                        }
                        .listStyle(.plain)
                    } else if results.isEmpty {
                        ContentUnavailableView.search(text: query)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 18) {
                                ForEach(results) { product in
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
                            .padding(.horizontal, 12)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                TextField("Поиск", text: $query)
                    .textFieldStyle(.roundedBorder)
                        .focused($isFocused)
                        .padding()
                        .onSubmit {
                            searchService.addToHistory(query)
                        }
            }
            .onAppear { isFocused = true }
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(productId: product.id)
            }
            .onChange(of: query) {
                searchTask?.cancel()
                searchTask = Task {
                    try? await Task.sleep(for: .milliseconds(500))
                    guard !Task.isCancelled else { return }
                    results = searchService.search(query)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.left")
                    }
                }
            }
        }
    }
}

#Preview {
    SearchView()
        .environment(
            SearchService(productService:
            ProductService(),
            categoryService: CategoryService()),
        )
        .environment(CartService())
        .environment(FavoriteService())
        
}

