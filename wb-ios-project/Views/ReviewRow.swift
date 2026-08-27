//
//  ReviewRow.swift
//  wb-ios-project
//
//

import SwiftUI
import DesignSystem

struct ReviewRow: View {
    let review: Review

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                HStack(spacing: 1) {
                    ForEach(1...5, id: \.self) { index in
                        Image(systemName: index <= review.rating ? "star.fill" : "star")
                            .font(.system(size: 9))
                    }
                }

                Text(review.author)
                    .font(DSTypography.caption)
                    .fontWeight(.semibold)

                Text(ProductDisplayFormat.reviewDate(review.createdAt))
                    .font(DSTypography.caption)
                    .foregroundStyle(.secondary)
            }

            Text(review.content)
                .font(DSTypography.caption)
                .fixedSize(horizontal: false, vertical: true)

            if !review.imageURLs.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.imageURLs, id: \.self) { url in
                            RemoteImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: 64, height: 64)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ReviewRow(
        review: Review(
            rating: 5,
            author: "Дарья",
            createdAt: .now,
            content: "Заказывала этот бутерброд на завтрак, когда не было времени готовить.",
            imageURLs: []
        )
    )
    .padding()
}
