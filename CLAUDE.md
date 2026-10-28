# Clinkr

An iPhone app with a companion Apple Watch app, written in SwiftUI. It's a hobby project, and the owner is new to iOS development, so explain Apple-specific concepts briefly when they come up.

## Layout

| Path | Target | Notes |
|---|---|---|
| `Clinkr/` | Clinkr (iOS 26+) | iPhone app. Bundle ID `com.colaiacovo.clinkr` |
| `Clinkr Watch App/` | Clinkr Watch App (watchOS 26+) | Watch app, embedded in the iPhone app. Bundle ID `com.colaiacovo.clinkr.watchkitapp` |
| `ClinkrTests/` | ClinkrTests | iPhone unit tests (Swift Testing) |
| `ClinkrUITests/` | ClinkrUITests | iPhone UI tests (XCTest) |
| `Clinkr Watch AppTests/` | Clinkr Watch AppTests | Watch unit tests (Swift Testing) |
| `scripts/test.sh` | | Lint and tests, used by CI too |
| `docs/ARCHITECTURE.md` | | Mermaid diagrams of how the apps fit together |

Swift 6 language mode, so strict concurrency checking is on.

## Commands

```bash
scripts/test.sh          # lint + iPhone tests + Watch tests
scripts/test.sh lint     # swift-format lint only
scripts/test.sh ios      # iPhone unit + UI tests
scripts/test.sh watch    # Watch unit tests
xcrun swift-format format --in-place --recursive Clinkr "Clinkr Watch App" ClinkrTests ClinkrUITests "Clinkr Watch AppTests"
```

Run `scripts/test.sh` before calling a change done. Build output goes to `build/` (gitignored).

## Rules

- Follow `CONTRIBUTING.md` for branches, commit messages, versions and releases. Bigger changes go on a `feature/`, `fix/` or `chore/` branch with a pull request, merged with squash.
- `main` is protected: never force-push it.
- Code style comes from `.swift-format` (4-space indent, 120-column lines). CI fails on lint errors.
- The project file `Clinkr.xcodeproj/project.pbxproj` is managed in Xcode. When adding files, put them in the target's folder and make sure they're added to the right target. When editing the file by hand, keep Debug and Release settings in sync.
- Version (`MARKETING_VERSION`) and build (`CURRENT_PROJECT_VERSION`) are set at the project level, so the iPhone and Watch apps always match. Apple requires that.
- Put code that both apps need in a place both targets can compile, rather than copying it.
