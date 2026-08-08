//
//  SearchButton.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 8/5/26.
//

import SwiftUI
import DesignSystem

struct SearchButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                Text("Поиск")
            }
            .foregroundStyle(.secondary)
            .font(DSTypography.subtitle)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.regularMaterial, in: Capsule())
            .shadow(radius: 8, y: 4)
        }
        .buttonStyle(.plain)

    }
}

#Preview {
    SearchButton(action: {})
}
