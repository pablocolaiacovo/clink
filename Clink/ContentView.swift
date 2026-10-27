import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wineglass")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Clink")
                .font(.largeTitle.bold())
            Text("Hello from iPhone")
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
