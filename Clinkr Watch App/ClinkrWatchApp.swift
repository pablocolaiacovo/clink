import SwiftUI

@main
struct ClinkrWatchApp: App {
    /// Tonight's drinks, loaded from disk at launch. Screens read it with `@Environment(NightStore.self)`.
    @State private var nightStore = NightStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(nightStore)
        }
    }
}
