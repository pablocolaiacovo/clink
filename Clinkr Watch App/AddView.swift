import SwiftUI

/// The Add screen: a button per drink in two columns, with a full-width water pill underneath. One tap adds one drink
/// to tonight.
struct AddView: View {
    @Environment(NightStore.self) private var nightStore

    private let columns = [GridItem(.flexible(), spacing: Space.s2), GridItem(.flexible(), spacing: Space.s2)]

    /// The drinks in the grid, in reading order. Water gets its own button underneath.
    static let gridDrinks = DrinkType.allCases.filter(\.countsAsDrink)

    var body: some View {
        ScrollView {
            VStack(spacing: Space.s2) {
                LazyVGrid(columns: columns, spacing: Space.s2) {
                    ForEach(Self.gridDrinks, id: \.self) { type in
                        DrinkButton(type: type, onAdd: add)
                    }
                }
                DrinkButton(type: .water, onAdd: add)
            }
            .padding(.horizontal, Space.s2)
        }
        .background(.bg)
    }

    private func add(_ type: DrinkType) {
        nightStore.add(type)
    }
}

#Preview {
    AddView()
        .environment(NightStore.preview())
}
