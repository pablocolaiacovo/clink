import SwiftUI
import WatchKit

/// The Watch app's screens, in swipe order: Tonight, Add, then Night.
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
    @State private var page = Page.tonight
    /// The night just ended, while "Night saved" shows with its Undo.
    @State private var endedNight: Night.ID?

    private enum Page {
        case tonight, add, night
    }

    /// The count is taken when the entry is added, so the toast doesn't change number while it slides away after an
    /// undo.
    private struct Undoable: Equatable {
        let entry: DrinkEntry
        let count: Int
    }

    var body: some View {
        // The stack gives the clock its own space, so the grid scrolls under it cleanly.
        NavigationStack {
            TabView(selection: $page) {
                TonightView()
                    .overlay(alignment: .bottom) { undoToast }
                    .tag(Page.tonight)
                AddView()
                    .safeAreaInset(edge: .bottom, spacing: 0) { undoToast }
                    .tag(Page.add)
                NightView(onEnd: endNight)
                    .tag(Page.night)
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
        .overlay {
            if let endedNight {
                NightSavedView(
                    onUndo: { reopenNight(endedNight) },
                    onDismiss: closeNightSaved
                )
                .transition(.opacity)
            }
        }
        .task(id: endedNight) {
            // Undo lasts as long as the toast's. Under VoiceOver it stays until closed, so it isn't cut off mid-read.
            guard endedNight != nil, !voiceOverEnabled else { return }
            do {
                try await Task.sleep(for: UndoToast.duration)
            } catch {
                return
            }
            closeNightSaved()
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

    /// Saves the night and goes back to an empty Tonight, ready for the next one.
    private func endNight() {
        let id = nightStore.activeNight?.id
        nightStore.endNight()
        WKInterfaceDevice.current().play(.success)
        withAnimation(Motion.standard) {
            page = .tonight
            endedNight = id
        }
    }

    /// Takes back End night and returns to the Night page it was ended from. If the night can't come back, the message
    /// just closes over the empty Tonight.
    private func reopenNight(_ id: Night.ID) {
        guard nightStore.reopenNight(id: id) else {
            closeNightSaved()
            return
        }
        WKInterfaceDevice.current().play(.click)
        withAnimation(Motion.standard) {
            page = .night
            endedNight = nil
        }
        if voiceOverEnabled {
            AccessibilityNotification.Announcement(String(localized: "Night reopened")).post()
        }
    }

    private func closeNightSaved() {
        withAnimation(Motion.standard) {
            endedNight = nil
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
