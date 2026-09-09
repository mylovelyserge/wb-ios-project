//
//  OrdersView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct OrdersView: View {
    @State private var orderService = OrderService()
    @State private var errorMessage: String?

    var body: some View {
        List {
            if orderService.isLoading && orderService.orders.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if orderService.orders.isEmpty {
                ContentUnavailableView("Заказов пока нет", systemImage: "bag")
            } else {
                ForEach(orderService.orders) { order in
                    NavigationLink {
                        OrderDetailsView(order: order)
                    } label: {
                        OrderRow(order: order)
                    }
                }
            }
        }
        .navigationTitle("Заказы")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            await orderService.loadOrders()
        }
        .task {
            await orderService.loadOrders()
        }
        .onChange(of: orderService.errorMessage) { _, newValue in
            errorMessage = newValue
        }
        .alert("Ошибка", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "")
        }
    }
}

private struct OrderRow: View {
    let order: CustomerOrder

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: order.status.systemImage)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(.purple)
                .frame(width: 42, height: 42)
                .background(Color.purple.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 4) {
                Text("Заказ #\(order.id)")
                    .font(DSTypography.body)
                    .lineLimit(1)
                Text("\(order.status.title) • \(order.etaText)")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text("\(order.totalItems) поз. • \(ProductDisplayFormat.totalPrice(order.totalPrice))")
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    NavigationStack {
        OrdersView()
    }
}
