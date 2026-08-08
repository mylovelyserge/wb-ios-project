//
//  CatalogView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 6/30/26.
//

import SwiftUI

struct CatalogView: View {
    @Environment(CategoryService.self) private var service
    @State private var isSearchPresented = false
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomLeading) {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(service.categories) { category in
                            NavigationLink {
                                ProductListView(categoryID: category.id)
                            } label: {
                                CategoryCard(category: category)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 12)
                }
                
                SearchButton {
                    isSearchPresented = true
                }
                .padding(12)
            }
            .navigationTitle("Каталог")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await service.load()
            }
            .fullScreenCover(isPresented: $isSearchPresented) {
                SearchView()
            }
        }
    }
}

#Preview {
    CatalogView()
        .environment(SearchService(productService: ProductService(), categoryService: CategoryService()))
}
