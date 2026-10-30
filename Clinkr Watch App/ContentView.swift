import SwiftUI

/// The Watch app's screens. Only Add for now; Tonight (#7) and Night come next, in that swipe order.
struct ContentView: View {
    var body: some View {
        AddView()
    }
}

#Preview {
    ContentView()
        .environment(NightStore(fileURL: .temporaryDirectory.appending(path: "preview-nights.json")))
}
