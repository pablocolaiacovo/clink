import SwiftUI

/// The Watch app's screens. Only Add for now; Tonight (#7) and Night come next, in that swipe order.
///
/// The Undo toast sits over every screen, so it shows after any add, wherever it came from.
struct ContentView: View {
    @Environment(NightStore.self) private var nightStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var undoable: Undoable?

    /// The count is taken when the entry is added, so the toast doesn't change number while it slides away after an
    /// undo.
    private struct Undoable: Equatable {
        let entry: DrinkEntry
        let count: Int
    }

    var body: some View {
        // The stack gives the clock its own space, so the grid scrolls under it cleanly.
        NavigationStack {
            AddView()
        }
        .overlay(alignment: .bottom) {
            if let undoable {
                UndoToast(type: undoable.entry.type, count: undoable.count) {
                    nightStore.removeEntry(id: undoable.entry.id)
                }
                .padding(.horizontal, Space.s2)
                .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onChange(of: nightStore.lastAdded) { _, entry in
            withAnimation(.snappy(duration: 0.3)) {
                undoable = entry.map { Undoable(entry: $0, count: count(like: $0)) }
            }
        }
        .task(id: undoable?.entry.id) {
            guard undoable != nil else { return }
            do {
                try await Task.sleep(for: UndoToast.duration)
            } catch {
                return
            }
            withAnimation(.snappy(duration: 0.3)) {
                undoable = nil
            }
        }
    }

    private func count(like entry: DrinkEntry) -> Int {
        guard let night = nightStore.activeNight else { return 0 }
        return entry.type.countsAsDrink ? night.drinkCount : night.waterCount
    }
}

#Preview {
    ContentView()
        .environment(NightStore.preview())
}
