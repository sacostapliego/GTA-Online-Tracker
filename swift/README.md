# Swift Frontend (iOS, SwiftUI)

This folder contains a modern SwiftUI frontend for the GTA Online tracker backend JSON. The app has three tabs: **Home**, **Bonuses**, and **Discounts**.

## Structure

- `App`: app entry point
- `Models`: Codable models matching backend output
- `Services`: API/data loading layer
- `ViewModels`: screen state and parsing logic
- `Views`: SwiftUI interface (HomeTabView, BonusesTabView, DiscountsTabView, MainTabView)
- `Resources`: sample JSON files from `scraper/data`

## Running in the iOS Simulator

### Option 1: Xcode (recommended)

1. Open the project in Xcode:
   ```bash
   open swift/GTAOnlineTracker.xcodeproj
   ```
2. Select an iPhone simulator from the device dropdown (e.g. iPhone 16).
3. Press `⌘R` or click the Run button to build and launch.

### Option 2: Command line

From the project root:

```bash
# Build for simulator (replace "iPhone 16" with your preferred device)
xcodebuild -project swift/GTAOnlineTracker.xcodeproj -scheme GTAOnlineTracker \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  -derivedDataPath swift/build build
```

Then open the Simulator and run the app:

```bash
# Boot simulator and launch the app
open -a Simulator
xcrun simctl install booted swift/build/Build/Products/Debug-iphonesimulator/GTAOnlineTracker.app
xcrun simctl launch booted com.sacosta.gtaonlinetracker
```

List available simulators: `xcrun simctl list devices available`

## Backend contract used

- `weekly-update.json`
- `vehicle_data.json`

## Quick setup in Xcode

1. Open `swift/GTAOnlineTracker.xcodeproj` in Xcode.
2. Add both sample JSON files in `Resources` to the app target if not already included.
3. If you host backend JSON remotely, set `TrackerAPI(baseURL: "https://your-host/path")` in `DashboardViewModel` init usage.

If `baseURL` is empty, the app loads bundled sample JSON.
