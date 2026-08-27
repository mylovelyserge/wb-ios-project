//
//  LoadingErrorView.swift
//  wb-ios-project
//
//

import SwiftUI

struct LoadingErrorView: View {
    let title: String
    let message: String
    let retryTitle: String
    let onRetry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: "wifi.exclamationmark")
        } description: {
            Text(message)
        } actions: {
            Button(retryTitle) {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    LoadingErrorView(
        title: "Не удалось загрузить товары",
        message: "Проверьте подключение и попробуйте снова",
        retryTitle: "Повторить",
        onRetry: {}
    )
}
