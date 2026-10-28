# Clinkr

An iPhone app with a companion Apple Watch app, built with SwiftUI.

## Requirements

- Xcode 27 or later
- iOS 26.0+ / watchOS 26.0+

## Project layout

| Folder | Target | What it is |
|---|---|---|
| `Clinkr/` | Clinkr | The iPhone app |
| `Clinkr Watch App/` | Clinkr Watch App | The Apple Watch app (embedded in the iPhone app) |

## Running

1. Open `Clinkr.xcodeproj` in Xcode.
2. Pick a scheme in the toolbar:
   - **Clinkr** runs the iPhone app.
   - **Clinkr Watch App** runs the Watch app on a paired Watch simulator.
3. Pick a simulator or device and press ⌘R.

To run on your own devices, select each target, open **Signing & Capabilities**, and choose your team (your Apple ID).

## Testing

```bash
scripts/test.sh
```

This checks the code style with swift-format, then runs the iPhone unit and UI tests and the Watch unit tests on the newest simulators. In Xcode, press ⌘U to run the tests for the selected scheme. GitHub Actions runs the same script on every pull request and push to `main`.

## Workflow

Branching, versioning and release steps are in [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).
