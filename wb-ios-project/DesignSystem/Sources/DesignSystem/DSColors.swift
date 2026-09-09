//
//  File.swift
//  DesignSystem
//
//  Created by Sergei Biriukov on 7/21/26.
//

import SwiftUI

public enum DSColors {
    public static let appBackground = Color(red: 244/255, green: 243/255, blue: 248/255)
    public static let cardBackground = Color.white
    public static let mutedBackground = Color(.systemGray6)
    public static let brand = Color(red: 153/255, green: 0/255, blue: 255/255)

    public static let brandGradient = LinearGradient(
        colors: [
            Color(red: 237/255, green: 60/255, blue: 202/255),
            Color(red: 102/255, green: 0/255, blue: 255/255)
        ],
        startPoint: .leading,
        endPoint: .trailing)
}
