//
//  AddressFormView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct AddressFormView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var address: DeliveryAddress
    @State private var isSaving = false
    let title: String
    let mode: Mode
    let onSave: (DeliveryAddress) async -> Bool
    let onDelete: (() async -> Void)?

    enum Mode {
        case add
        case edit
    }

    init(
        address: DeliveryAddress,
        title: String,
        mode: Mode = .add,
        onSave: @escaping (DeliveryAddress) async -> Bool,
        onDelete: (() async -> Void)? = nil
    ) {
        _address = State(initialValue: address)
        self.title = title
        self.mode = mode
        self.onSave = onSave
        self.onDelete = onDelete
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 244 / 255, green: 243 / 255, blue: 248 / 255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        if mode == .edit {
                            titleAddressField
                        } else {
                            addAddressField
                        }

                        formGroup(title: "Подъезд") {
                            UnderlineTextField(title: "Этаж", text: $address.floor, keyboardType: .numberPad)
                            UnderlineTextField(title: "Подъезд", text: $address.entrance)
                            UnderlineTextField(title: "Домофон", text: $address.intercomCode)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Комментарий")
                                .font(DSTypography.subtitle)
                                .foregroundStyle(.secondary)

                            TextField("Комментарий курьеру", text: $address.comment, axis: .vertical)
                                .font(DSTypography.body)
                                .lineLimit(4...7)
                                .padding(18)
                                .frame(minHeight: 118, alignment: .topLeading)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 26))
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 26)
                    .padding(.bottom, 110)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                Task { await save() }
            } label: {
                HStack(spacing: 10) {
                    if isSaving {
                        ProgressView()
                            .tint(.white)
                    }
                    Text("Сохранить")
                        .font(.system(size: 20, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(isValid ? DSColors.brandGradient : LinearGradient(colors: [.gray.opacity(0.25)], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .disabled(!isValid || isSaving)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background(.white)
        }
    }

    private var header: some View {
        ZStack(alignment: .top) {
            MapPlaceholderView()
                .frame(height: 190)
                .clipShape(RoundedRectangle(cornerRadius: 26))
                .padding(.horizontal, 24)
                .padding(.top, 8)

            HStack(alignment: .top) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: mode == .edit ? "chevron.left" : "xmark")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(.secondary)
                        .frame(width: 54, height: 54)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }
                .accessibilityLabel(mode == .edit ? "Назад" : "Закрыть")

                Spacer()

                if mode == .edit {
                    Button("Указать на карте") {}
                        .font(DSTypography.subtitle)
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 22)
                        .frame(height: 54)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                }

                Spacer()

                if mode == .edit, let onDelete {
                    Button(role: .destructive) {
                        Task {
                            await onDelete()
                            dismiss()
                        }
                    } label: {
                        Image(systemName: "trash")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(.pink)
                            .frame(width: 54, height: 54)
                            .background(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                    .accessibilityLabel("Удалить адрес")
                } else {
                    Color.clear.frame(width: 54, height: 54)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 28)
        }
    }

    private var addAddressField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Адрес")
                .font(DSTypography.subtitle)
                .foregroundStyle(.secondary)

            TextField("Улица, дом, квартира", text: $address.addressLine, axis: .vertical)
                .font(DSTypography.body)
                .lineLimit(2...4)
                .padding(18)
                .frame(minHeight: 84, alignment: .topLeading)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }

    private var titleAddressField: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(address.addressLine.isEmpty ? "Новый адрес" : address.addressLine)
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            UnderlineTextField(title: "Квартира/офис", text: $address.addressLine)
        }
    }

    private func formGroup<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(DSTypography.subtitle)
                .foregroundStyle(.secondary)

            VStack(spacing: 0) {
                content()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 26))
        }
    }

    private var isValid: Bool {
        !address.addressLine.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() async {
        guard isValid, !isSaving else { return }
        isSaving = true
        let didSave = await onSave(address)
        isSaving = false
        if didSave {
            dismiss()
        }
    }
}

private struct UnderlineTextField: View {
    let title: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default

    var body: some View {
        TextField(title, text: $text)
            .font(DSTypography.body)
            .keyboardType(keyboardType)
            .padding(.vertical, 14)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.16))
                    .frame(height: 1)
            }
    }
}

private struct MapPlaceholderView: View {
    var body: some View {
        ZStack {
            Color(red: 226 / 255, green: 230 / 255, blue: 225 / 255)

            VStack(spacing: 22) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(.white.opacity(0.7))
                    .frame(height: 18)
                    .rotationEffect(.degrees(-8))
                RoundedRectangle(cornerRadius: 6)
                    .fill(.white.opacity(0.85))
                    .frame(height: 18)
                    .rotationEffect(.degrees(7))
                RoundedRectangle(cornerRadius: 6)
                    .fill(.white.opacity(0.65))
                    .frame(height: 18)
                    .rotationEffect(.degrees(-5))
            }
            .padding(.horizontal, -30)

            Circle()
                .fill(Color.blue)
                .frame(width: 14, height: 14)
                .overlay {
                    Circle()
                        .stroke(.white, lineWidth: 4)
                        .frame(width: 24, height: 24)
                }
        }
    }
}

#Preview("Add") {
    AddressFormView(address: .empty, title: "Новый адрес") { _ in true }
}

#Preview("Edit") {
    AddressFormView(address: DeliveryAddress(
        id: "1",
        addressLine: "Челябинск, ул. Габдуллы Тукая, 3, 26",
        longitude: 37.6173,
        latitude: 55.7558,
        floor: "3",
        entrance: "4",
        intercomCode: "15809",
        comment: ""
    ), title: "Редактировать", mode: .edit) { _ in true }
}
