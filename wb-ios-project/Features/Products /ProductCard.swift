//
//  ProductCard.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/2/26.
//

import SwiftUI

struct ProductCard: View {
    let product: Product
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            AsyncImage(url: product.imageURL) { image in
                image
                    .resizable()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } placeholder: {
                Color.gray
            }
            
            Text("\(product.price) ₽")
                .font(.system(size: 18, weight: .semibold))
                .padding(.top, 8)
            
            HStack {
                Text(product.name)
                    .lineLimit(1)
                Spacer()
                Text("\(Int(product.weight)) г")
                    .foregroundStyle(.secondary)
            }
            .font(.system(size: 14, weight: .regular))
            
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                    Text(String(format: "%.1f", product.rating))
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "message")
                        .font(.system(size: 11))
                    Text("\(product.reviewCount)")
                }
            }
            
            Button {
                //
            } label: {
                Text("В корзину")
                    .foregroundStyle(.black)
                    .font(.system(size: 14, weight: .semibold))
                    .padding(.vertical, 6)
                    .padding(.horizontal, 12)
                    .background(Color(red: 0.96, green: 0.93, blue: 0.98))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.top, 12)
        }
    }
}

#Preview {
    ProductCard(product: Product.mocks[0])
}
