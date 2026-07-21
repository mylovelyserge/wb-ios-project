//
//  ProductDetailView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/8/26.
//

import SwiftUI
import DesignSystem

struct ProductDetailView: View {
    
    private func reviewsWord(for count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = lastTwoDigits % 10
        
        if (11...14).contains(lastTwoDigits) {
            return "отзывов"
        }
        switch lastDigit {
        case 1:
            return "отзыв"
        case 2...4:
            return "отзыва"
        default:
            return "отзывов"
        }
    }
    
    
    let productId: String
    @State private var service = ProductDetailService()
    @State private var showConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(CartService.self) private var cartService
    var body: some View {
        Group {
            if service.isLoading {
                ProgressView()
            } else if let product = service.product {
                ScrollView {
                    VStack(alignment: .leading) {
                        ZStack(alignment: .topTrailing) {
                            AsyncImage(url: product.imageURL) { image in
                                image
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                            } placeholder: {
                                Color.gray
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                            }
                            
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.system(size: 24))
                            .buttonStyle(.plain)
                            .padding(20)

                        }
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("\(product.price) ₽")
                                    .font(DSTypography.title)
                                Spacer()
                                
                                Button {
                                    
                                } label: {
                                    Image(systemName: product.isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 30))
                                        .foregroundStyle(product.isFavorite ? .pink : .secondary)
                                        
                                }
                                .buttonStyle(.plain)

                            }
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text(product.name)
                                Text("\(Int(product.weight)) г")
                                    .foregroundStyle(.secondary)
                            }
                            .font(DSTypography.headline)
                            
                            HStack(spacing: 3) {
                                Text(String(format: "%.1f", product.rating))
                                    .font(DSTypography.body)
                                
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= Int(product.rating.rounded()) ? "star.fill" : "star")
                                        .font(.system(size: 12))
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "message")
                                        .font(.system(size: 12))
                                    Text("\(product.reviewsCount) \(reviewsWord(for: product.reviewsCount))")
                                        .font(DSTypography.body)
                                }
                                .padding(.horizontal, 10)
                            }
                            
                            Text(product.description)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 12)
                    }
                }
                .safeAreaInset(edge: .bottom) {
                    Button {
                        cartService.add(
                            product: Product(
                                id: product.id,
                                name: product.name,
                                imageURL: product.imageURL,
                                price: product.price,
                                weight: product.weight,
                                rating: product.rating,
                                reviewCount: product.reviewsCount)
                        )
                        withAnimation { showConfirmation = true }
                        Task {
                                try? await Task.sleep(for: .seconds(1.5))
                                withAnimation { showConfirmation = false }
                            }
                    } label: {
                        Text(showConfirmation ? "✓ Добавлено" : "В корзину")
                            .foregroundStyle(.white)
                            .font(DSTypography.subtitle)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(DSColors.brandGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(12)
                }
                
            } else {
                Text("Товар не найден")
            }
        }
        .task {
            await service.load(productId: productId)
        }
    }
}

#Preview {
    ProductDetailView(productId: "1")
        .environment(CartService())
}
