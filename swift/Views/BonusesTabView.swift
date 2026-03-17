import SwiftUI

struct BonusesTabView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading bonuses...")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else if let weekly = viewModel.weeklyUpdate {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header(weekly: weekly)
                        bonusesList(items: weekly.bonuses)
                    }
                    .padding(20)
                }
            } else {
                Text(viewModel.errorMessage ?? "No data available.")
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(24)
            }
        }
        .task {
            await viewModel.load()
        }
    }

    private var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.08, green: 0.06, blue: 0.04),
                Color(red: 0.14, green: 0.10, blue: 0.08)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func header(weekly: WeeklyUpdate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Bonuses")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(weekly.weekOf)
                .font(.subheadline)
                .foregroundStyle(Color.orange.opacity(0.9))
        }
    }

    private func bonusesList(items: [String]) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, bonus in
                bonusRow(text: bonus, index: index)
            }
        }
    }

    private func bonusRow(text: String, index: Int) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 48, height: 48)

                Text("\(index + 1)")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.orange)
            }

            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.orange.opacity(0.35), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.3))
                )
        )
    }
}
