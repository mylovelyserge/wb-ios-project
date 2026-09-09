//
//  ProfileView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var service = ProfileService()
    @State private var draft = UserProfile.empty
    @State private var errorMessage: String?
    @State private var isSaved = false
    @State private var isActionMenuPresented = false
    @State private var isDeleteConfirmationPresented = false

    var body: some View {
        NavigationStack {
            ZStack {
                DSColors.appBackground
                    .ignoresSafeArea()

                Group {
                    if service.isLoading && service.profile == nil {
                        ProgressView()
                    } else if service.profile == nil, let errorMessage = service.errorMessage {
                        LoadingErrorView(
                            title: "Не удалось загрузить профиль",
                            message: errorMessage,
                            retryTitle: "Повторить",
                            onRetry: {
                                Task { await service.load() }
                            }
                        )
                    } else {
                        profileCard
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .task {
                await service.load()
                if let profile = service.profile {
                    draft = profile
                }
            }
            .onChange(of: service.profile) { _, newValue in
                if let newValue {
                    withAnimation(.snappy) {
                        draft = newValue
                    }
                }
            }
            .onChange(of: service.errorMessage) { _, newValue in
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
            .alert("Профиль сохранен", isPresented: $isSaved) {
                Button("OK", role: .cancel) {}
            }
            .confirmationDialog("Профиль", isPresented: $isActionMenuPresented, titleVisibility: .hidden) {
                Button("Выйти") {
                    Task { await service.logout() }
                }
                Button("Удалить профиль", role: .destructive) {
                    isDeleteConfirmationPresented = true
                }
                Button("Отмена", role: .cancel) {}
            }
            .alert("Удалить профиль?", isPresented: $isDeleteConfirmationPresented) {
                Button("Удалить", role: .destructive) {
                    Task { await deleteProfile() }
                }
                Button("Отмена", role: .cancel) {}
            } message: {
                Text("Данные профиля будут сброшены на сервере")
            }
        }
    }

    private var profileCard: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 24, weight: .regular))
                        .foregroundStyle(Color(red: 151 / 255, green: 151 / 255, blue: 178 / 255))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Назад")

                Spacer()

                Button {
                    isActionMenuPresented = true
                } label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 24, weight: .regular))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color(red: 151 / 255, green: 151 / 255, blue: 178 / 255))
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Действия")
            }
            .overlay(alignment: .top) {
                avatar
                    .offset(y: 14)
            }
            .padding(.horizontal, 14)
            .padding(.top, 18)
            .frame(height: 134, alignment: .top)

            VStack(spacing: 22) {
                ProfileUnderlineField(title: "Имя", text: $draft.name)

                ProfileLockedPhoneField(phone: draft.phone)

                ProfileUnderlineField(title: "День рождения", text: $draft.birthday, placeholder: "01.01.1999")

                Button {
                    Task { await save() }
                } label: {
                    HStack(spacing: 8) {
                        if service.isSaving {
                            ProgressView()
                                .tint(.white)
                        }
                        Text("Сохранить изменения")
                            .font(.system(size: 18, weight: .bold))
                    }
                }
                .buttonStyle(.dsPrimary)
                .opacity(canSave ? 1 : 0.35)
                .disabled(!canSave || service.isSaving)
                .padding(.top, 4)

                profileLinks
                    .padding(.top, 6)
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 28)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 28, topTrailingRadius: 28))
        .padding(.top, 62)
        .ignoresSafeArea(edges: .bottom)
    }

    private var avatar: some View {
        RemoteImage(url: draft.imageURL) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            ZStack {
                Color(red: 229 / 255, green: 223 / 255, blue: 239 / 255)
                Text(initial)
                    .font(.system(size: 46, weight: .regular))
                    .foregroundStyle(.black)
            }
        }
        .frame(width: 86, height: 86)
        .clipShape(Circle())
    }

    private var profileLinks: some View {
        VStack(spacing: 0) {
            NavigationLink {
                OrdersView()
            } label: {
                ProfileLinkRow(title: "Мои заказы", systemImage: "bag")
            }

            Divider()
                .padding(.leading, 48)

            NavigationLink {
                AddressesView()
            } label: {
                ProfileLinkRow(title: "Мои адреса", systemImage: "mappin.and.ellipse")
            }
        }
    }

    private var initial: String {
        let trimmedName = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedName.first.map { String($0).uppercased() } ?? "A"
    }

    private var canSave: Bool {
        !draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !draft.birthday.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        draft != service.profile
    }

    private func save() async {
        let didSave = await service.save(draft)
        if didSave {
            isSaved = true
        }
    }

    private func deleteProfile() async {
        let didDelete = await service.deleteProfile()
        if didDelete {
            draft = service.profile ?? .empty
        }
    }
}

private struct ProfileUnderlineField: View {
    let title: String
    @Binding var text: String
    var placeholder = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(DSTypography.caption)
                .foregroundStyle(Color(red: 151 / 255, green: 151 / 255, blue: 178 / 255))
            TextField(title, text: $text, prompt: Text(placeholder.isEmpty ? title : placeholder))
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(.primary)
                .padding(.bottom, 7)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(Color(red: 238 / 255, green: 234 / 255, blue: 242 / 255))
                        .frame(height: 2)
                }
        }
    }
}

private struct ProfileLockedPhoneField: View {
    let phone: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Телефон")
                .font(DSTypography.caption)
                .foregroundStyle(Color(red: 151 / 255, green: 151 / 255, blue: 178 / 255))

            HStack(spacing: 5) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14))
                Text(phone.isEmpty ? "Не указан" : phone)
                    .font(.system(size: 18, weight: .regular))
            }
            .foregroundStyle(Color(red: 151 / 255, green: 151 / 255, blue: 178 / 255))
            .padding(.bottom, 7)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(Color(red: 238 / 255, green: 234 / 255, blue: 242 / 255))
                    .frame(height: 2)
            }
        }
    }
}

private struct ProfileLinkRow: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .foregroundStyle(DSColors.brand)
                .frame(width: 32, height: 32)
                .background(DSColors.brand.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 9))
            Text(title)
                .foregroundStyle(.primary)
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .font(DSTypography.body)
        .padding(.vertical, 14)
    }
}

#Preview {
    ProfileView()
        .environment(CartService())
        .environment(FavoriteService())
}
