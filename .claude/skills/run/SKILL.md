---
name: run
description: Build and launch Clinkr on the iOS and watchOS simulators to see a change working. Use when asked to run, launch, try, or screenshot the iPhone or Watch app.
---

# Run Clinkr in the simulators

The iPhone app and the Watch app run on separate simulators. Run whichever one the change touches, or both.

## iPhone app

1. Pick an available iPhone simulator on the newest iOS runtime. `scripts/test.sh` has a `simulator_id` helper that shows how.
2. Build:

   ```bash
   xcodebuild build -project Clinkr.xcodeproj -scheme Clinkr -destination "id=<iphone-udid>" -derivedDataPath build/DerivedData -quiet
   ```

3. The app is at `build/DerivedData/Build/Products/Debug-iphonesimulator/Clinkr.app`.
4. If the iOS Simulator tool is available, open its live panel first (`attach`) so the user can watch. Then `launch` the app with that path. Otherwise:

   ```bash
   xcrun simctl boot <iphone-udid> || true
   open -a Simulator
   xcrun simctl install <iphone-udid> build/DerivedData/Build/Products/Debug-iphonesimulator/Clinkr.app
   xcrun simctl launch <iphone-udid> com.colaiacovo.clinkr
   ```

## Watch app

1. Pick an available Apple Watch simulator on the newest watchOS runtime.
2. Build the `Clinkr Watch App` scheme the same way with `-destination "id=<watch-udid>"`.
3. The app is at `build/DerivedData/Build/Products/Debug-watchsimulator/Clinkr Watch App.app`. Its bundle ID is `com.colaiacovo.clinkr.watchkitapp`.
4. Install and launch it on the Watch simulator as above.

## Checking the result

Take a screenshot and confirm the change is visible. Report what you saw. If the build fails, show the first error rather than the whole log.
