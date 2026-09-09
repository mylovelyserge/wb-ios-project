//
//  SplashView.swift
//  wb-ios-project
//

import SwiftUI
import DesignSystem

struct SplashView: View {
    var body: some View {
        ZStack {
            DSColors.brandGradient
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 46, weight: .semibold))
                    .foregroundStyle(.white)

                Text("wb darkstore")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(.white)
            }
        }
    }
}

#Preview {
    SplashView()
}
