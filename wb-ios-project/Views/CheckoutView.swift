//
//  CheckoutView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct CheckoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CartService.self) private var cartService
    @State private var addressService = AddressService()
    @State private var orderService = OrderService()
    @State private var selectedAddressID: String?
    @State private var errorMessage: String?
    @State private var isOrderCreated = false
    @State private var isAddingAddress = false

    var body: some View {
        NavigationStack {
            List {
                Section("Заказ") {
                    HStack {
                        Text("Товары")
                        Spacer()
                        Text("\(cartService.totalCount)")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Сумма")
                        Spacer()
                        Text(ProductDisplayFormat.totalPrice(cartService.totalPrice))
                            .font(DSTypography.subtitle)
                    }
                }

                Section {
                    if addressService.isLoading && addressService.addresses.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, alignment: .center)
                    } else if addressService.addresses.isEmpty {
                        ContentUnavailableView("Добавьте адрес доставки", systemImage: "mappin.and.ellipse")
                    } else {
                        ForEach(addressService.addresses) { address in
                            Button {
                                selectedAddressID = address.id
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: selectedAddressID == address.id ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedAddressID == address.id ? Color.purple : Color.secondary)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(address.addressLine)
                                            .foregroundStyle(.primary)
                                        Text(addressDetails(for: address))
                                            .font(DSTypography.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } header: {
                    Text("Адрес доставки")
                } footer: {
                    NavigationLink("Управлять адресами") {
                        AddressesView()
                    }
                }
            }
            .navigationTitle("Оформление")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { await submitOrder() }
                } label: {
                    HStack {
                        if orderService.isSubmitting {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Оформить заказ")
                            .font(DSTypography.subtitle)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(DSColors.brandGradient)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(selectedAddressID == nil || orderService.isSubmitting || cartService.items.isEmpty)
                .padding()
                .background(.bar)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isAddingAddress = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Добавить адрес")
                }
            }
            .task {
                await addressService.load()
                if selectedAddressID == nil {
                    selectedAddressID = addressService.addresses.first?.id
                }
            }
            .onChange(of: addressService.addresses) { _, addresses in
                if selectedAddressID == nil || !addresses.contains(where: { $0.id == selectedAddressID }) {
                    selectedAddressID = addresses.first?.id
                }
            }
            .onChange(of: addressService.errorMessage) { _, newValue in
                errorMessage = newValue
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
            .alert("Заказ оформлен", isPresented: $isOrderCreated) {
                Button("OK") {
                    cartService.clear()
                    dismiss()
                }
            } message: {
                Text("Мы передали заказ в обработку")
            }
            .sheet(isPresented: $isAddingAddress) {
                AddressFormView(address: .empty, title: "Новый адрес") { address in
                    await addressService.save(address)
                }
            }
        }
    }

    private func submitOrder() async {
        guard let selectedAddressID else { return }
        let didCreate = await orderService.createOrder(addressID: selectedAddressID)
        if didCreate {
            isOrderCreated = true
        }
    }

    private func addressDetails(for address: DeliveryAddress) -> String {
        let parts = [
            address.entrance.isEmpty ? nil : "подъезд \(address.entrance)",
            address.floor.isEmpty ? nil : "этаж \(address.floor)",
            address.intercomCode.isEmpty ? nil : "домофон \(address.intercomCode)"
        ].compactMap { $0 }

        return parts.isEmpty ? "Детали не указаны" : parts.joined(separator: ", ")
    }
}

#Preview {
    let service = CartService()
    service.add(product: Product.mocks[0])
    return CheckoutView()
        .environment(service)
}
