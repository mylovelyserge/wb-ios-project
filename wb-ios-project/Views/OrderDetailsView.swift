//
//  OrderDetailsView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct OrderDetailsView: View {
    let order: CustomerOrder

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                statusHeader
                totalsSection
                addressSection
                itemsSection
            }
            .padding(16)
        }
        .navigationTitle("Детали заказа")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusHeader: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: order.status.systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(.purple)
                .frame(width: 52, height: 52)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(order.status.title)
                    .font(DSTypography.subtitle)
                Text(order.etaText)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var totalsSection: some View {
        VStack(spacing: 12) {
            totalRow(title: "Товары", value: ProductDisplayFormat.totalPrice(order.orderPrice))
            totalRow(title: "Доставка", value: ProductDisplayFormat.totalPrice(order.deliveryPrice))
            Divider()
            totalRow(title: "Итого", value: ProductDisplayFormat.totalPrice(order.totalPrice), isAccent: true)
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Адрес доставки")
                .font(DSTypography.subtitle)
            Text(order.address.addressLine)
                .font(DSTypography.body)

            let details = [
                order.address.entrance.isEmpty ? nil : "подъезд \(order.address.entrance)",
                order.address.floor.isEmpty ? nil : "этаж \(order.address.floor)",
                order.address.intercomCode.isEmpty ? nil : "домофон \(order.address.intercomCode)"
            ].compactMap { $0 }

            if !details.isEmpty {
                Text(details.joined(separator: ", "))
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }

            if !order.address.comment.isEmpty {
                Text(order.address.comment)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var itemsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Состав заказа")
                .font(DSTypography.subtitle)

            ForEach(order.items) { item in
                OrderProductRow(item: item)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func totalRow(title: String, value: String, isAccent: Bool = false) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(isAccent ? .primary : .secondary)
            Spacer()
            Text(value)
                .font(isAccent ? DSTypography.subtitle : DSTypography.body)
        }
    }
}

private struct OrderProductRow: View {
    let item: OrderProduct

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RemoteImage(url: item.imageURL) { image in
                image
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
            } placeholder: {
                Color.gray.opacity(0.15)
            }
            .frame(width: 64, height: 64)
            .clipShape(RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(DSTypography.body)
                    .lineLimit(2)
                Text("\(item.weight) г")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                Text("\(item.quantity) x \(ProductDisplayFormat.price(item.price))")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(ProductDisplayFormat.totalPrice(item.price * item.quantity))
                .font(DSTypography.subtitle)
        }
    }
}

#Preview {
    NavigationStack {
        OrderDetailsView(order: CustomerOrder(
            id: "1",
            status: .processing,
            deliveryDate: nil,
            address: OrderAddress(
                addressLine: "Челябинск, ул. Габдуллы Тукая, 3, 26",
                floor: "3",
                entrance: "4",
                intercomCode: "15809",
                comment: ""
            ),
            orderPrice: 900,
            deliveryPrice: 149,
            totalPrice: 1049,
            totalItems: 2,
            items: [
                OrderProduct(id: "1", name: "Бутер с колбасой", imageURL: Product.mocks[0].imageURL, weight: 100, price: 900, quantity: 1)
            ]
        ))
    }
}
