import SwiftUI

/// The Add screen: a button per drink in two columns, with a full-width water pill underneath. One tap adds one drink
/// to tonight.
struct AddView: View {
    @Environment(NightStore.self) private var nightStore

    private let columns = [GridItem(.flexible(), spacing: Space.s2), GridItem(.flexible(), spacing: Space.s2)]

    var body: some View {
        ScrollView {
            VStack(spacing: Space.s2) {
                LazyVGrid(columns: columns, spacing: Space.s2) {
                    ForEach(DrinkType.allCases.filter(\.countsAsDrink), id: \.self) { type in
                        DrinkButton(type: type) { nightStore.add(type) }
                    }
                }
                DrinkButton(type: .water) { nightStore.add(.water) }
            }
            .padding(.horizontal, Space.s2)
        }
        .background(.bg)
    }
}

#Preview {
    AddView()
        .environment(NightStore(fileURL: .temporaryDirectory.appending(path: "preview-nights.json")))
}
