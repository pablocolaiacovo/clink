import SwiftUI

/// The Night screen, third in the swipe order: "End night", then tonight's drinks and waters, newest first. Swiping a
/// row left removes it, like a later undo.
struct NightView: View {
    @Environment(NightStore.self) private var nightStore
    let onEnd: () -> Void

    /// Hour and minute, plus the weekday on a night long enough for times to repeat.
    static func timeFormat(for night: Night) -> Date.FormatStyle {
        night.spansMoreThanADay ? .dateTime.weekday(.abbreviated).hour().minute() : .dateTime.hour().minute()
    }

    var body: some View {
        List {
            if let night = nightStore.activeNight {
                endButton
                    .listRowBackground(Color.clear)
                ForEach(night.newestFirst) { entry in
                    EntryRow(entry: entry, timeFormat: Self.timeFormat(for: night))
                        .listRowBackground(RoundedRectangle(cornerRadius: Radius.card).fill(.surface))
                        // No full swipe: removing has no undo, so it takes the swipe and then a tap.
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button {
                                nightStore.removeEntry(id: entry.id)
                            } label: {
                                Label("Remove", systemImage: "trash.fill")
                            }
                            .tint(.surfaceRaised)
                        }
                }
            } else {
                Text("Drinks you add show up here.")
                    .typeStyle(.watchCaption)
                    .foregroundStyle(.inkMuted)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
            }
        }
        .scrollContentBackground(.hidden)
        .background(.bg)
    }

    private var endButton: some View {
        Button(action: onEnd) {
            Text("End night")
                .typeStyle(.watchBody)
                .foregroundStyle(.onPop)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.horizontal, Space.s3)
                .frame(maxWidth: .infinity, minHeight: Size.primaryPill)
                .background(.fizz, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

/// One logged drink or water: its glyph in its color, its name and the time it was added.
private struct EntryRow: View {
    let entry: DrinkEntry
    let timeFormat: Date.FormatStyle

    var body: some View {
        HStack(spacing: Space.s2) {
            entry.type.glyph
                .resizable()
                .frame(width: Size.rowGlyph, height: Size.rowGlyph)
                .foregroundStyle(entry.type.color)
                .accessibilityHidden(true)
            Text(entry.type.displayName)
                .typeStyle(.watchBody)
                .foregroundStyle(.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer(minLength: Space.s1)
            Text(entry.timestamp, format: timeFormat)
                .typeStyle(.watchCaption)
                .monospacedDigit()
                .foregroundStyle(.inkMuted)
                .lineLimit(1)
        }
        .frame(minHeight: Size.minTarget)
        .accessibilityElement(children: .combine)
    }
}

/// Shown for a moment after ending the night, over a Tonight that's already reset for the next one. Undo takes the
/// end back.
struct NightSavedView: View {
    let onUndo: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Night saved. Get home safe.")
                .typeStyle(.watchTitle)
                .foregroundStyle(.ink)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                // Only the message closes it, so a tap that just misses Undo doesn't throw the undo away.
                .contentShape(Rectangle())
                .onTapGesture(perform: onDismiss)
                // With VoiceOver it stays until closed, so the message itself closes it.
                .accessibilityAddTraits(.isButton)
                .accessibilityHint(Text("Closes this message"))
                .accessibilityAction(.default, onDismiss)
            UndoButton(action: onUndo)
                .padding(.vertical, Space.s3)
        }
        .padding(.horizontal, Space.s2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.bg)
        // Taps around Undo stop here rather than reaching the screen underneath.
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .accessibilityAddTraits(.isModal)
        .onAppear {
            AccessibilityNotification.ScreenChanged(nil).post()
        }
    }
}

#Preview("Tonight") {
    let store = NightStore.preview()
    for type in [DrinkType.beer, .water, .wine, .shot] {
        store.add(type)
    }
    return NightView {}
        .environment(store)
}

#Preview("Before the night") {
    NightView {}
        .environment(NightStore.preview())
}

#Preview("Saved") {
    NightSavedView(onUndo: {}, onDismiss: {})
}
