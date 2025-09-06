//
//  ClothesDetectionDemoApp.swift
//  ClothesDetectionDemo
//
//  Created by Harsh Vardhan Kushwaha on 06/07/25.
//

import SwiftUI

@main
struct ClothesDetectionDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.container, DIContainer.shared)
        }
    }
}
