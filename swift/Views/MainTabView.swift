import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTabView(viewModel: viewModel)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            BonusesTabView(viewModel: viewModel)
                .tabItem {
                    Label("Bonuses", systemImage: "dollarsign.circle.fill")
                }
                .tag(1)

            DiscountsTabView(viewModel: viewModel)
                .tabItem {
                    Label("Discounts", systemImage: "tag.fill")
                }
                .tag(2)
        }
        .tint(.orange)
        .onAppear {
            configureTabBarAppearance()
        }
    }

    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.05, blue: 0.04, alpha: 1)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
