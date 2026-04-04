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
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    .padding(20)
                    .padding(.bottom, 56)
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
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.85)
                .lineLimit(2)

            Text(weekly.weekOf)
                .font(.subheadline)
                .foregroundStyle(Color.orange.opacity(0.9))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private func bonusesList(items: [BonusDisplayItem]) -> some View {
        VStack(spacing: 16) {
            ForEach(items) { item in
                bonusCard(item: item)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private func bonusCard(item: BonusDisplayItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Rectangle()
                .fill(Color.orange)
                .frame(height: 3)
                .frame(maxWidth: .infinity)

            // REVERT NOTE: Hero is intentionally *outside* horizontal padding so the image
            // spans the same width as the orange accent bar (full card width). If you prefer
            // inset images again, wrap `bonusHeroImage` + `Text` in a single `VStack { }.padding(12)`.
            bonusHeroImage(imageURL: item.imageURL, rewardBadge: item.rewardBadge)

            Text(item.activityName)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
                .textCase(.uppercase)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 12)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .background(bonusCardBackground)
    }

    private var bonusCardBackground: some View {
        Color(red: 0.12, green: 0.12, blue: 0.12)
    }

    private func bonusHeroImage(imageURL: String, rewardBadge: String) -> some View {
        // REVERT NOTE: This uses a plain ZStack + aspectRatio instead of Color.clear.overlay.
        // That combo was sometimes mis-sized in ScrollView, which looked like a narrow image
        // with side gutters and clipped the bottom-leading badge. `minWidth: 0` keeps the
        // hero from overflowing the card width on small devices.
        ZStack(alignment: .bottomLeading) {
            Group {
                AsyncImage(url: URL(string: imageURL)) { phase in
                    switch phase {
                    case .empty:
                        bonusPlaceholderFill
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    case .failure:
                        bonusPlaceholderFill
                    @unknown default:
                        bonusPlaceholderFill
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()

            // REVERT NOTE: Small inset so the badge sits fully inside the clipped 16:9 rect
            // (avoids the first character looking cut off on the left edge).
            if !rewardBadge.isEmpty {
                Text(rewardBadge)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.black)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .padding(.leading, 8)
                    .padding(.bottom, 8)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .aspectRatio(16 / 9, contentMode: .fit)
        .clipped()
    }

    private var bonusPlaceholderFill: some View {
        ZStack {
            Color.black.opacity(0.45)
            Image(systemName: "star.fill")
                .font(.title2)
                .foregroundStyle(.orange.opacity(0.55))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
