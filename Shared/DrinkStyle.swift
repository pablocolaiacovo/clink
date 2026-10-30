import SwiftUI

extension DrinkType {
    /// The drink's color token. A fill, never text: anything on it uses `.onPop`.
    var colorToken: ThemeColor {
        switch self {
        case .beer: Palette.beer
        case .wine: Palette.wine
        case .cocktail: Palette.cocktail
        case .shot: Palette.shot
        case .water: Palette.water
        }
    }

    var color: Color {
        colorToken.color
    }

    /// Name of the drink's glyph in `Shared/Glyphs.xcassets`.
    var glyphName: String {
        "glyph-\(rawValue)"
    }

    /// The drink's solid glyph. It takes its color from the context, like an SF Symbol: `.onPop` on the drink's
    /// color, or the drink's color on a dark background.
    var glyph: Image {
        Image(glyphName)
    }
}

#Preview("Drinks") {
    VStack(spacing: Space.s2) {
        ForEach(DrinkType.allCases, id: \.self) { type in
            HStack(spacing: Space.s3) {
                type.glyph
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.onPop)
                    .padding(Space.s3)
                    .background(type.color, in: .rect(cornerRadius: Radius.card))
                type.glyph
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(type.color)
                Text(type.displayName)
                    .typeStyle(.watchBody)
                    .foregroundStyle(.ink)
                Spacer()
            }
        }
    }
    .padding(Space.s4)
    .background(.bg)
}
