import SwiftUI

/// The Watch app's screens. Only Add for now; Tonight (#7) and Night come next, in that swipe order.
///
/// The Undo toast sits under every screen, so it shows after any add, wherever it came from.
struct ContentView: View {
    @Environment(NightStore.self) private var nightStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
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
            // An inset rather than an overlay, so the screen can still scroll every button clear of the toast. It
            // goes inside the stack, which doesn't pass an inset on to the scroll view.
            AddView()
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    if let undoable {
                        UndoToast(type: undoable.entry.type, count: undoable.count) {
                            nightStore.removeEntry(id: undoable.entry.id)
                        }
                        .padding(.horizontal, Space.s2)
                        .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
                    }
                }
        }
        .onChange(of: nightStore.lastAdded) { _, entry in
            withAnimation(UndoToast.animation) {
                undoable = entry.map { Undoable(entry: $0, count: count(like: $0)) }
            }
            if let undoable, voiceOverEnabled {
                let message = String(localized: UndoToast.message(for: undoable.entry.type, count: undoable.count))
                AccessibilityNotification.Announcement(message).post()
            }
        }
        .task(id: undoable?.entry.id) {
            // VoiceOver needs time to reach Undo, so there the toast stays until the next add or an undo.
            guard undoable != nil, !voiceOverEnabled else { return }
            do {
                try await Task.sleep(for: UndoToast.duration)
            } catch {
                return
            }
            withAnimation(UndoToast.animation) {
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
