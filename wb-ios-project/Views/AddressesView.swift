//
//  AddressesView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct AddressesView: View {
    @State private var addressService = AddressService()
    @State private var editableAddress: DeliveryAddress?
    @State private var isAddingAddress = false
    @State private var errorMessage: String?

    var body: some View {
        List {
            if addressService.isLoading && addressService.addresses.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if addressService.addresses.isEmpty {
                ContentUnavailableView("Адресов пока нет", systemImage: "mappin.and.ellipse")
            } else {
                ForEach(addressService.addresses) { address in
                    Button {
                        editableAddress = address
                    } label: {
                        AddressRow(address: address)
                    }
                    .buttonStyle(.plain)
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task { await addressService.delete(address) }
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Мои адреса")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
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
        }
        .onChange(of: addressService.errorMessage) { _, newValue in
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
        .sheet(isPresented: $isAddingAddress) {
            AddressFormView(address: .empty, title: "Новый адрес") { address in
                await addressService.save(address)
            }
        }
        .sheet(item: $editableAddress) { address in
            AddressFormView(address: address, title: "Редактировать", mode: .edit) { address in
                await addressService.save(address)
            } onDelete: {
                await addressService.delete(address)
            }
        }
    }
}

private struct AddressRow: View {
    let address: DeliveryAddress

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(address.addressLine)
                .font(DSTypography.body)
                .foregroundStyle(.primary)

            let details = [
                address.entrance.isEmpty ? nil : "подъезд \(address.entrance)",
                address.floor.isEmpty ? nil : "этаж \(address.floor)",
                address.intercomCode.isEmpty ? nil : "домофон \(address.intercomCode)"
            ].compactMap { $0 }

            if !details.isEmpty {
                Text(details.joined(separator: ", "))
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }

            if !address.comment.isEmpty {
                Text(address.comment)
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AddressesView()
    }
}
