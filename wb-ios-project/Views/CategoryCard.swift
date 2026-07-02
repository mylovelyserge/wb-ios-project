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
            
            LinearGradient(
                stops: [
                    .init(color: .clear.opacity(0.1), location: 0.5),
                    .init(color: .white.opacity(0.9), location: 0.7),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            
            Text(category.name)
                .font(.system(size: 14, weight: .medium))
                .padding(.leading, 8)
                .padding(.bottom, 6)
        }
        .aspectRatio(1, contentMode: .fill)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    CategoryCard(category: Category.mocks[0])
}

