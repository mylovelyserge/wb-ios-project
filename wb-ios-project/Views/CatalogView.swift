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
        ScrollView {
            LazyVGrid(columns: columns, spacing: 2) {
                ForEach(Category.mocks) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal, 12)
        }
        .task {
            await service.load()
        }
    }
}

#Preview {
    CatalogView()
}
