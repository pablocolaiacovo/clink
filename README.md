# Clink

An iPhone app with a companion Apple Watch app, built with SwiftUI.

## Requirements

- Xcode 27 or later
- iOS 26.0+ / watchOS 26.0+

## Project layout

| Folder | Target | What it is |
|---|---|---|
| `Clink/` | Clink | The iPhone app |
| `Clink Watch App/` | Clink Watch App | The Apple Watch app (embedded in the iPhone app) |

## Running

1. Open `Clink.xcodeproj` in Xcode.
2. Pick a scheme in the toolbar:
   - **Clink** runs the iPhone app.
   - **Clink Watch App** runs the Watch app on a paired Watch simulator.
3. Pick a simulator or device and press ⌘R.

To run on your own devices, select each target, open **Signing & Capabilities**, and choose your team (your Apple ID).

## License

MIT. See [LICENSE](LICENSE).
