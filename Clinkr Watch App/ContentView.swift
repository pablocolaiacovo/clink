import SwiftUI
import WatchKit

/// The Watch app's screens, in swipe order: Tonight, then Add. Night (#10) comes third.
///
/// The Undo toast and the water break nudge sit over every screen, so they follow any add, wherever it came from.
struct ContentView: View {
    @Environment(NightStore.self) private var nightStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @State private var undoable: Undoable?
    @State private var waterNudge = WaterNudge()
    @State private var showsWaterNudge = false
    /// The drink that makes the nudge due, waiting for its Undo toast to go first.
    @State private var pendingNudge: DrinkEntry.ID?

    /// The count is taken when the entry is added, so the toast doesn't change number while it slides away after an
    /// undo.
    private struct Undoable: Equatable {
        let entry: DrinkEntry
        let count: Int
    }

    var body: some View {
        // The stack gives the clock its own space, so the grid scrolls under it cleanly.
        NavigationStack {
            TabView {
                TonightView()
                    .overlay(alignment: .bottom) { undoToast }
                AddView()
                    .safeAreaInset(edge: .bottom, spacing: 0) { undoToast }
            }
            .tabViewStyle(.verticalPage)
        }
        .overlay {
            if showsWaterNudge, let night = nightStore.activeNight {
                WaterNudgeView(
                    drinkCount: night.drinkCount,
                    waterCount: night.waterCount,
                    onHadOne: {
                        closeWaterNudge()
                        WKInterfaceDevice.current().play(DrinkType.water.addHaptic)
                        nightStore.add(.water)
                    },
                    onLater: {
                        waterNudge.markDismissed(at: .now)
                        closeWaterNudge()
                    },
                    onUndo: undoable.map { undoable in
                        { nightStore.removeEntry(id: undoable.entry.id) }
                    }
                )
                .transition(reduceMotion ? .opacity : .move(edge: .bottom))
            }
        }
        .onChange(of: nightStore.lastAdded) { _, entry in
            // An undo or a water clears it, and another drink takes its place.
            pendingNudge = entry.flatMap { entry in
                guard let night = nightStore.activeNight, waterNudge.shouldShow(for: night, at: entry.timestamp) else {
                    return nil
                }
                return entry.id
            }
            withAnimation(UndoToast.animation) {
                undoable = entry.map { Undoable(entry: $0, count: count(like: $0)) }
            }
            if let undoable, voiceOverEnabled {
                let message = String(localized: UndoToast.message(for: undoable.entry.type, count: undoable.count))
                AccessibilityNotification.Announcement(message).post()
            }
        }
        .onChange(of: nudgeIsDue) { _, isDue in
            // Covers an undo with VoiceOver on, where the toast outlasts its 5 seconds, and the night going away.
            if !isDue {
                closeWaterNudge()
            }
        }
        .task(id: pendingNudge) {
            // The nudge waits out the toast's time, so the drink that brought it on can still be undone.
            guard let pendingNudge else { return }
            do {
                try await Task.sleep(for: UndoToast.duration)
            } catch {
                return
            }
            guard nightStore.lastAdded?.id == pendingNudge else { return }
            showWaterNudge()
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

    /// Add takes the toast as an inset, so its list can scroll every button clear of it. Tonight takes it as an
    /// overlay, since an inset would shrink the ring. Each page adds it itself: the stack doesn't pass an inset on to
    /// a page's scroll view.
    @ViewBuilder
    private var undoToast: some View {
        if let undoable {
            UndoToast(type: undoable.entry.type, count: undoable.count) {
                nightStore.removeEntry(id: undoable.entry.id)
            }
            .padding(.horizontal, Space.s2)
            .transition(reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity))
        }
    }

    private var nudgeIsDue: Bool {
        nightStore.activeNight.map(WaterNudge.isDue(in:)) ?? false
    }

    private func showWaterNudge() {
        waterNudge.markShown(at: .now)
        WKInterfaceDevice.current().play(.notification)
        withAnimation(WaterNudgeView.animation) {
            showsWaterNudge = true
        }
    }

    private func closeWaterNudge() {
        withAnimation(WaterNudgeView.animation) {
            showsWaterNudge = false
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
