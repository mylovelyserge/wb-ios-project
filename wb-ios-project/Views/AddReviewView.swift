//
//  AddReviewView.swift
//  wb-ios-project
//
//

import SwiftUI
import DesignSystem

struct AddReviewView: View {
    let isSubmitting: Bool
    let onSubmit: (Int, String) async -> Bool

    @Environment(\.dismiss) private var dismiss
    @State private var rating = 5
    @State private var content = ""
    @State private var validationMessage: String?

    private var trimmedContent: String {
        content.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var canSubmit: Bool {
        !trimmedContent.isEmpty && !isSubmitting
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Оценка")
                        .font(DSTypography.subtitle)

                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { value in
                            Button {
                                rating = value
                            } label: {
                                Image(systemName: value <= rating ? "star.fill" : "star")
                                    .font(.system(size: 30))
                                    .foregroundStyle(value <= rating ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Отзыв")
                        .font(DSTypography.subtitle)

                    TextEditor(text: $content)
                        .frame(minHeight: 160)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(alignment: .topLeading) {
                            if content.isEmpty {
                                Text("Расскажите, что понравилось или что можно улучшить")
                                    .foregroundStyle(.secondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 16)
                                    .allowsHitTesting(false)
                            }
                        }
                }

                if let validationMessage {
                    Text(validationMessage)
                        .font(DSTypography.caption)
                        .foregroundStyle(.red)
                }

                Spacer()
            }
            .padding(16)
            .navigationTitle("Написать отзыв")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отмена") {
                        dismiss()
                    }
                    .disabled(isSubmitting)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await submit()
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView()
                        } else {
                            Text("Готово")
                        }
                    }
                    .disabled(!canSubmit)
                }
            }
        }
    }

    private func submit() async {
        guard canSubmit else {
            validationMessage = "Добавьте текст отзыва"
            return
        }

        validationMessage = nil
        let didSubmit = await onSubmit(rating, trimmedContent)
        if !didSubmit {
            validationMessage = "Не удалось отправить отзыв"
        }
    }
}

#Preview {
    AddReviewView(isSubmitting: false, onSubmit: { _, _ in true })
}
