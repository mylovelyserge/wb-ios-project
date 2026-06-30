//
//  CatalogView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 6/30/26.
//

import SwiftUI

struct CatalogView: View {
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
    ]
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Category.mocks) { category in
                    CategoryCard(category: category)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    CatalogView()
}
