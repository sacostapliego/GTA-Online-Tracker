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
                        bonusesList(items: viewModel.bonusItems())
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

    private func bonusesList(items: [BonusDisplayItem]) -> some View {
        VStack(spacing: 12) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                bonusRow(item: item, index: index)
            }
        }
    }

    private func bonusRow(item: BonusDisplayItem, index: Int) -> some View {
        HStack(alignment: .top, spacing: 14) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .empty:
                    bonusPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    bonusPlaceholder
                @unknown default:
                    bonusPlaceholder
                }
            }
            .frame(width: 120, height: 76)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 8) {
                Text(item.text)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
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

    private var bonusPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.black.opacity(0.4))
            .overlay {
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundStyle(.orange.opacity(0.5))
            }
    }
}
