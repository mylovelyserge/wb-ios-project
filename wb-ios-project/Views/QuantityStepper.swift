//
//  QuantityStepper.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 7/16/26.
//

import SwiftUI

struct QuantityStepper: View {
    let quantity: Int
    let onDecrease: () -> Void
    let onIncrease: () -> Void
    
    var body: some View {
        
        HStack(spacing: 0) {
            Button {
                onDecrease()
            } label: {
                Image(systemName: "minus")
                    .frame(width: 40)
                    .contentShape(Rectangle())
                    .font(.system(size: 16,weight: .regular))
            }
            .buttonStyle(.plain)
            Spacer()
            
            Text("\(quantity)")
                .font(.system(size: 16,weight: .medium))
            Spacer()
            
            Button {
                onIncrease()
            } label: {
                Image(systemName: "plus")
                    .frame(width: 40)
                    .contentShape(Rectangle())
                    .font(.system(size: 16,weight: .regular))
            }
            .buttonStyle(.plain)
        }
        .frame(minWidth: 106, maxWidth: 140)
        .frame(height: 32)
        .background(Color(.systemGray6), in: Rectangle())
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    QuantityStepper(quantity: 5, onDecrease: {}, onIncrease: {})
}
