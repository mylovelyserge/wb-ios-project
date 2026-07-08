//
//  CartView.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/8/26.
//

import SwiftUI

struct CartView: View {
    var body: some View {
        NavigationStack {
            Text("Корзина")
                .navigationTitle("Корзина")
        }
    }
}

#Preview {
    CartView()
}
