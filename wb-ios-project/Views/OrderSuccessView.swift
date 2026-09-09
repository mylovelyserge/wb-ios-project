//
//  OrderSuccessView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct OrderSuccessView: View {
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            DSColors.brandGradient
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                    .frame(height: 235)

                Image(systemName: "checkmark")
                    .font(.system(size: 96, weight: .ultraLight))
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)

                Text("Заказ\nоформлен")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                    .lineSpacing(-4)
                    .padding(.bottom, 12)

                Text("Товары уже в процессе сборки,\nскоро привезем!")
                    .font(DSTypography.body)
                    .foregroundStyle(.white.opacity(0.86))

                Spacer()

                Button {
                    onClose()
                } label: {
                    Text("Закрыть")
                        .font(DSTypography.subtitle)
                        .foregroundStyle(DSColors.brand)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
                .padding(.bottom, 28)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .light))
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
            }
            .accessibilityLabel("Закрыть")
            .padding(.top, 40)
            .padding(.trailing, 8)
        }
    }
}

#Preview {
    OrderSuccessView(onClose: {})
}
