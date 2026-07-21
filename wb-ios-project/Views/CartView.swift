//
//  CartView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/8/26.
//

import SwiftUI
import DesignSystem

struct CartView: View {
    @Environment(CartService.self) private var cartService
    var body: some View {
        NavigationStack {
            Group {
                if cartService.items.isEmpty {
                    ContentUnavailableView("Корзина пуста", systemImage: "cart")
                } else {
                    ScrollView {
                        ForEach(cartService.items) { item in
                            CartItemRow(item: item)
                        }
                    }
                    .padding(.horizontal, 12)
                    .safeAreaInset(edge: .bottom) {
                        HStack {
                            Text("Итого: \(cartService.totalPrice) ₽")
                            Spacer()
                            Button {
                                //
                            } label: {
                                Text("Оформить")
                                    .foregroundStyle(.white)
                                    .font(DSTypography.subtitle)
                                    .padding(.vertical, 12)
                                    .padding(.horizontal, 24)
                                    .background(DSColors.brandGradient)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }

                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Корзина")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview("С товарами") {
    let service = CartService()
    service.add(product: Product.mocks[0])
    service.add(product: Product.mocks[0])
    service.add(product: Product.mocks[3])
    service.add(product: Product.mocks[4])
    return CartView()
        .environment(service)
}

#Preview("Пустая") {
    CartView()
        .environment(CartService())
}
