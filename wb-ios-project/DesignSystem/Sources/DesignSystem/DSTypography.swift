//
//  DSTypography.swift
//  DesignSystem
//
//  Created by Sergei Biriukov on 7/22/26.
//

import SwiftUI

public enum DSTypography {

    // Крупная цена и главные заголовки экранов (было: 32 medium в деталях)
    public static let title: Font = .system(size: 32, weight: .medium)

    // Название товара — крупное (было: 26 medium в деталях)
    public static let headline: Font = .system(size: 26, weight: .medium)

    // Акцентный текст: цены в списках, текст кнопок
    // (свёл 20/18/17 semibold → один размер; несогласованность цен убрана)
    public static let subtitle: Font = .system(size: 18, weight: .semibold)

    // Обычный текст: описание, контрол количества (было: 16 regular)
    public static let body: Font = .system(size: 16, weight: .regular)

    // Вторичное: вес, названия в мелких местах, счётчик отзывов
    // (свёл 14 regular/medium → regular как базовый)
    public static let caption: Font = .system(size: 14, weight: .regular)

    // Самое мелкое: звёзды, иконки рейтинга (свёл 12/11 → 12)
    public static let footnote: Font = .system(size: 12, weight: .regular)
}
