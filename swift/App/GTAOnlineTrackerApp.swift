import SwiftUI

@main
struct GTAOnlineTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: DashboardViewModel())
        }
    }
}
