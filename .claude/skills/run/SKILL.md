---
name: run
description: Build and launch Clink on the iOS and watchOS simulators to see a change working. Use when asked to run, launch, try, or screenshot the iPhone or Watch app.
---

# Run Clink in the simulators

The iPhone app and the Watch app run on separate simulators. Run whichever one the change touches, or both.

## iPhone app

1. Pick an available iPhone simulator on the newest iOS runtime. `scripts/test.sh` has a `simulator_id` helper that shows how.
2. Build:

   ```bash
   xcodebuild build -project Clink.xcodeproj -scheme Clink -destination "id=<iphone-udid>" -derivedDataPath build/DerivedData -quiet
   ```

3. The app is at `build/DerivedData/Build/Products/Debug-iphonesimulator/Clink.app`.
4. If the iOS Simulator tool is available, open its live panel first (`attach`) so the user can watch. Then `launch` the app with that path. Otherwise:

   ```bash
   xcrun simctl boot <iphone-udid> || true
   open -a Simulator
   xcrun simctl install <iphone-udid> build/DerivedData/Build/Products/Debug-iphonesimulator/Clink.app
   xcrun simctl launch <iphone-udid> com.colaiacovo.clink
   ```

## Watch app

1. Pick an available Apple Watch simulator on the newest watchOS runtime.
2. Build the `Clink Watch App` scheme the same way with `-destination "id=<watch-udid>"`.
3. The app is at `build/DerivedData/Build/Products/Debug-watchsimulator/Clink Watch App.app`. Its bundle ID is `com.colaiacovo.clink.watchkitapp`.
4. Install and launch it on the Watch simulator as above.

## Checking the result

Take a screenshot and confirm the change is visible. Report what you saw. If the build fails, show the first error rather than the whole log.
