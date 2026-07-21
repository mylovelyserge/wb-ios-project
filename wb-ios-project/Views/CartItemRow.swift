//
//  CartItemRow.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/12/26.
//

import SwiftUI
import DesignSystem

struct CartItemRow: View {
    @Environment(CartService.self) private var cartService
    let item: CartItem
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            AsyncImage(url: item.product.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } placeholder: {
                Color.gray
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("\(item.product.price) ₽")
                    .font(DSTypography.subtitle)
                
                HStack(alignment: .firstTextBaseline) {
                    Text(item.product.name)
                    Text("\(Int(item.product.weight)) г")
                        .foregroundStyle(.secondary)
                }
                .font(DSTypography.caption)
                
                
                QuantityStepper(
                    quantity: item.quantity,
                    onDecrease: { cartService.decrease(product: item.product) },
                    onIncrease: { cartService.increase(product: item.product) }
                )
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear {
            print("CART IMG:", item.product.imageURL?.absoluteString ?? "nil")
        }
    }
}

#Preview {
    CartItemRow(item: CartItem.mocks[0])
        .environment(CartService())
}
