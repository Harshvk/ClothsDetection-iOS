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
