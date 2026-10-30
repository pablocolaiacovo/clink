import SwiftUI

/// The bar that shows for a few seconds after every add, so a mistap in the dark is one tap to take back. No
/// confirmation: Undo removes the entry straight away.
struct UndoToast: View {
    static let duration: Duration = .seconds(5)

    let type: DrinkType
    /// Tonight's drinks including this one, or tonight's waters when it's a water.
    let count: Int
    let onUndo: () -> Void

    var body: some View {
        // Spanish runs longer, so the button drops its title, then moves under the message, before the message is cut.
        ViewThatFits(in: .horizontal) {
            bar(showsUndoTitle: true)
            bar(showsUndoTitle: false)
            card
        }
    }

    static func message(for type: DrinkType, count: Int) -> LocalizedStringResource {
        if type.countsAsDrink {
            LocalizedStringResource("Cheers! That's \(count).", comment: "Undo toast after adding a drink")
        } else {
            LocalizedStringResource("Water! That's \(count).", comment: "Undo toast after adding a water")
        }
    }

    private func bar(showsUndoTitle: Bool) -> some View {
        HStack(spacing: Space.s2) {
            message
            undoButton(showsTitle: showsUndoTitle, fillsWidth: false)
        }
        .padding(.leading, Space.s3)
        .padding(.trailing, Space.s1)
        .padding(.vertical, Space.s1)
        .background(.surfaceRaised, in: Capsule())
    }

    private var card: some View {
        VStack(spacing: Space.s1) {
            message
            undoButton(showsTitle: true, fillsWidth: true)
        }
        .padding(Space.s1)
        .padding(.top, Space.s1)
        .background(.surfaceRaised, in: RoundedRectangle(cornerRadius: Radius.card))
    }

    private var message: some View {
        Text(Self.message(for: type, count: count))
            .typeStyle(.watchBody)
            .foregroundStyle(.ink)
            .lineLimit(1)
    }

    private func undoButton(showsTitle: Bool, fillsWidth: Bool) -> some View {
        Button(action: onUndo) {
            undoLabel(showsTitle: showsTitle)
                .typeStyle(.watchBody)
                .foregroundStyle(.bg)
                .padding(.horizontal, Space.s3)
                .frame(minWidth: Size.minTarget, maxWidth: fillsWidth ? .infinity : nil, minHeight: Size.minTarget)
                .background(.ink, in: Capsule())
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func undoLabel(showsTitle: Bool) -> some View {
        let label = Label(
            LocalizedStringResource("Undo", comment: "Button that removes the drink just added"),
            systemImage: "arrow.uturn.backward"
        )
        if showsTitle {
            label.labelStyle(.titleOnly)
        } else {
            label.labelStyle(.iconOnly)
        }
    }
}

#Preview {
    VStack(spacing: Space.s2) {
        UndoToast(type: .beer, count: 4) {}
        UndoToast(type: .water, count: 1) {}
    }
    .padding(.horizontal, Space.s2)
}
