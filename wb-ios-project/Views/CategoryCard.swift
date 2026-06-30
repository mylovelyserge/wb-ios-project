//
//  CategoryCard.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 6/30/26.
//

import SwiftUI

struct CategoryCard: View {
    let category: Category
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            AsyncImage(url: category.imageURL) { image in
                image
                    .resizable()
                    .scaledToFill()
            } placeholder: {
                Color.gray
            }
            Text(category.name)
                .padding(12)
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

#Preview {
    CategoryCard(category: Category.mocks[0])
}

