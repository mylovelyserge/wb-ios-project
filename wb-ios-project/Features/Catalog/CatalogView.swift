//
//  CatalogView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 6/30/26.
//

import SwiftUI

struct CatalogView: View {
    @State private var service = CategoryService()
    let columns = [
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
        GridItem(.flexible(), spacing: 2),
    ]
    var body: some View {
        NavigationStack {
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
            .task {
                await service.load()
            }
        }
    }
}

#Preview {
    CatalogView()
}
