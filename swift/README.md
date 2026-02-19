# Swift Frontend (iOS, SwiftUI)

This folder contains a modern SwiftUI frontend for the GTA Online tracker backend JSON.

## Structure

- `GTAOnlineTracker/App`: app entry point
- `GTAOnlineTracker/Models`: Codable models matching backend output
- `GTAOnlineTracker/Services`: API/data loading layer
- `GTAOnlineTracker/ViewModels`: screen state and parsing logic
- `GTAOnlineTracker/Views`: SwiftUI interface
- `GTAOnlineTracker/Resources`: sample JSON files from `scraper/data`

## Backend contract used

- `weekly-update.json`
- `vehicle_data.json`

## Quick setup in Xcode

1. Create a new iOS App project named `GTAOnlineTracker` (SwiftUI lifecycle).
2. Replace generated source files with files from `Swift/GTAOnlineTracker`.
3. Add both sample JSON files in `Swift/GTAOnlineTracker/Resources` to the app target.
4. If you host backend JSON remotely, set `TrackerAPI(baseURL: "https://your-host/path")` in `DashboardViewModel` init usage.

If `baseURL` is empty, the app loads bundled sample JSON.
