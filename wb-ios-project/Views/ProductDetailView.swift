//
//  ProductDetailView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/8/26.
//

import SwiftUI
import DesignSystem

struct ProductDetailView: View {
    let productId: String
    @State private var service = ProductDetailService()
    @State private var showConfirmation = false
    
    @Environment(\.dismiss) private var dismiss
    @Environment(CartService.self) private var cartService
    @Environment(FavoriteService.self) private var favoriteService
    var body: some View {
        Group {
            if service.isLoading {
                ProgressView()
            } else if let product = service.product {
                ScrollView {
                    VStack(alignment: .leading) {
                        ZStack(alignment: .topTrailing) {
                            RemoteImage(url: product.imageURL) { image in
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
                                Text(ProductDisplayFormat.price(product.price))
                                    .font(DSTypography.title)
                                Spacer()
                                
                                Button {
                                    favoriteService.toggle(product: product.product)
                                } label: {
                                    Image(systemName: favoriteService.contains(productId: product.id) ? "heart.fill" : "heart")
                                        .font(.system(size: 30))
                                        .foregroundStyle(favoriteService.contains(productId: product.id) ? .pink : .secondary)
                                        
                                }
                                .buttonStyle(.plain)

                            }
                            
                            HStack(alignment: .firstTextBaseline) {
                                Text(product.name)
                                Text(ProductDisplayFormat.weight(product.weight))
                                    .foregroundStyle(.secondary)
                            }
                            .font(DSTypography.headline)
                            
                            HStack(spacing: 3) {
                                Text(ProductDisplayFormat.rating(product.rating))
                                    .font(DSTypography.body)
                                
                                ForEach(1...5, id: \.self) { index in
                                    Image(systemName: index <= Int(product.rating.rounded()) ? "star.fill" : "star")
                                        .font(.system(size: 12))
                                }
                                
                                HStack(spacing: 6) {
                                    Image(systemName: "message")
                                        .font(.system(size: 12))
                                    Text(ProductDisplayFormat.reviews(product.reviewsCount))
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
                        cartService.add(product: product.product)
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
        .environment(FavoriteService())
}
