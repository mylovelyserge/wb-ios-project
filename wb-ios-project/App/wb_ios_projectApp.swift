//
//  wb_ios_projectApp.swift
//  wb-ios-project
//
//  Created by Sergei Biriukov on 6/30/26.
//

import SwiftUI

@main
struct wb_ios_projectApp: App {
    var body: some Scene {
        WindowGroup {
            TabView {
                Tab("Каталог", systemImage: "list.bullet") {
                    CatalogView()
                }
                
                Tab("Корзина", systemImage: "basket") {
                    CartView()
                }
            }
        }
    }
}
