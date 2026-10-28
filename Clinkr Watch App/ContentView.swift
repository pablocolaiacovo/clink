import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "wineglass")
                .font(.title)
                .foregroundStyle(.tint)
            Text("Clinkr")
                .font(.headline)
            Text("Hello from Watch")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    ContentView()
}
