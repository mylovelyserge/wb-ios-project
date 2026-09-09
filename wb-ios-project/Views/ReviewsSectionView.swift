//
//  ReviewsSectionView.swift
//  wb-ios-project
//
//

import SwiftUI
import DesignSystem

struct ReviewsSectionView: View {
    let reviews: [Review]
    let isSubmitting: Bool
    let errorMessage: String?
    let onSubmit: (Int, String) async -> Bool

    @State private var isFormPresented = false
    @State private var sortOption: ReviewSortOption = .dateNewest

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text("Отзывы")
                    .font(DSTypography.title)
                Text("\(reviews.count)")
                    .font(DSTypography.title)
                    .foregroundStyle(.secondary)
            }

            if reviews.isEmpty {
                ContentUnavailableView("Отзывов пока нет", systemImage: "text.bubble")
                    .frame(maxWidth: .infinity)
            } else {
                ReviewSummaryView(reviews: reviews)
            }

            if !reviews.isEmpty {
                Picker("Сортировка", selection: $sortOption) {
                    ForEach(ReviewSortOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            Button {
                isFormPresented = true
            } label: {
                Text("Написать отзыв")
                    .foregroundStyle(.primary)
                    .font(DSTypography.subtitle)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .buttonStyle(.plain)

            if let errorMessage {
                Text(errorMessage)
                    .font(DSTypography.caption)
                    .foregroundStyle(.red)
            }

            VStack(spacing: 12) {
                ForEach(sortedReviews) { review in
                    ReviewRow(review: review)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .animation(.snappy, value: sortOption)
        }
        .sheet(isPresented: $isFormPresented) {
            AddReviewView(isSubmitting: isSubmitting) { rating, content in
                let didSubmit = await onSubmit(rating, content)
                if didSubmit {
                    isFormPresented = false
                }
                return didSubmit
            }
        }
    }

    private var sortedReviews: [Review] {
        switch sortOption {
        case .dateNewest:
            return reviews.sorted { $0.createdAt > $1.createdAt }
        case .ratingHigh:
            return reviews.sorted {
                if $0.rating == $1.rating {
                    return $0.createdAt > $1.createdAt
                }
                return $0.rating > $1.rating
            }
        case .ratingLow:
            return reviews.sorted {
                if $0.rating == $1.rating {
                    return $0.createdAt > $1.createdAt
                }
                return $0.rating < $1.rating
            }
        }
    }
}

private enum ReviewSortOption: String, CaseIterable, Identifiable {
    case dateNewest
    case ratingHigh
    case ratingLow

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dateNewest:
            return "Дата"
        case .ratingHigh:
            return "Высокие"
        case .ratingLow:
            return "Низкие"
        }
    }
}

private struct ReviewSummaryView: View {
    let reviews: [Review]

    var body: some View {
        HStack(alignment: .top, spacing: 18) {
            Text(ProductDisplayFormat.rating(reviews.averageRating))
                .font(.system(size: 56, weight: .regular))
                .monospacedDigit()

            VStack(spacing: 3) {
                ForEach((1...5).reversed(), id: \.self) { rating in
                    RatingDistributionRow(
                        rating: rating,
                        count: reviews.count(for: rating),
                        total: reviews.count
                    )
                }
            }
        }
    }
}

private struct RatingDistributionRow: View {
    let rating: Int
    let count: Int
    let total: Int

    private var fraction: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }

    var body: some View {
        HStack(spacing: 6) {
            HStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.system(size: 8))
                }
            }
            .frame(width: 48, alignment: .leading)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                    Rectangle()
                        .fill(Color.secondary)
                        .frame(width: proxy.size.width * fraction)
                }
            }
            .frame(height: 1)

            Text("\(count)")
                .font(DSTypography.footnote)
                .foregroundStyle(.secondary)
                .monospacedDigit()
                .frame(width: 28, alignment: .trailing)
        }
    }
}

#Preview {
    ReviewsSectionView(
        reviews: [
            Review(rating: 5, author: "Дарья", createdAt: .now, content: "Заказывала этот бутерброд на завтрак, когда не было времени готовить.", imageURLs: []),
            Review(rating: 3, author: "Александр", createdAt: .now, content: "Ничто сказать... ожидал чего-то более достойного за эти деньги.", imageURLs: [])
        ],
        isSubmitting: false,
        errorMessage: nil,
        onSubmit: { _, _ in true }
    )
    .padding()
}
