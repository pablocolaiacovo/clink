import SwiftUI

/// The Watch app's screens. Only Add for now; Tonight (#7) and Night come next, in that swipe order.
struct ContentView: View {
    var body: some View {
        // The stack gives the clock its own space, so the grid scrolls under it cleanly.
        NavigationStack {
            AddView()
        }
    }
}

#Preview {
    ContentView()
        .environment(NightStore.preview())
}
