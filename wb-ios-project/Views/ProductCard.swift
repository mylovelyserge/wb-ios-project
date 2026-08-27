//
//  ProductCard.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/2/26.
//

import SwiftUI
import DesignSystem

struct ProductCard: View {
    let product: Product
    let onSelect: () -> Void
    let onAddToCart: () -> Void
    let onShowReviews: () -> Void
    
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                RemoteImage(url: product.imageURL) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    Color.gray
                }
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    onSelect()
                }
                
                Button {
                    onToggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(isFavorite ? .red : .white)
                        .frame(width: 44, height: 44)
                        .contentShape(Rectangle())
                        .shadow(radius: 2)
                }

            }
            
            Text(ProductDisplayFormat.price(product.price))
                .font(DSTypography.subtitle)
                .padding(.top, 8)
                .onTapGesture {
                    onSelect()
                }
            
            HStack {
                Text(product.name)
                    .lineLimit(1)
                Spacer()
                Text(ProductDisplayFormat.weight(product.weight))
                    .foregroundStyle(.secondary)
            }
            .font(DSTypography.caption)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect()
            }
            
            HStack(spacing: 4) {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(DSTypography.footnote)
                    Text(ProductDisplayFormat.rating(product.rating))
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect()
                }
                
                Button {
                    onShowReviews()
                } label: {
                    HStack(spacing: 2) {
                        Image(systemName: "message")
                            .font(DSTypography.footnote)
                        Text("\(product.reviewCount)")
                    }
                }
                .buttonStyle(.plain)
            }
            
            Button {
                onAddToCart()
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
    ProductCard(
        product: Product.mocks[0],
        onSelect: {},
        onAddToCart: {},
        onShowReviews: {},
        isFavorite: true,
        onToggleFavorite: {}
    )
}
