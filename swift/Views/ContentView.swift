import SwiftUI

struct ContentView: View {
    @StateObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading weekly update...")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else if let weekly = viewModel.weeklyUpdate {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        titleHeader(weekly: weekly)
                        challengeCard(text: weekly.weeklyChallenge)
                        spotlightSection(
                            title: "Podium Vehicle",
                            name: weekly.podiumVehicle,
                            subtitle: nil
                        )
                        spotlightSection(
                            title: "Prize Ride",
                            name: weekly.prizeRideVehicle,
                            subtitle: weekly.prizeRideChallenge
                        )
                        salvageSection(items: weekly.salvageYardRobberies)
                        discountsSection(items: viewModel.discountItems())
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
            colors: [Color(red: 0.05, green: 0.07, blue: 0.12), Color(red: 0.12, green: 0.15, blue: 0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private func titleHeader(weekly: WeeklyUpdate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GTA Online Tracker")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(weekly.weekOf)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.8))

            if let firstIntro = weekly.introMessages.first {
                Text(firstIntro)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.92))
                    .padding(.top, 4)
            }
        }
    }

    private func challengeCard(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Challenge")
                .font(.headline)
                .foregroundStyle(.white)

            Text(text)
                .foregroundStyle(.white.opacity(0.92))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.1))
        )
    }

    private func spotlightSection(title: String, name: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)

            AsyncImage(url: viewModel.imageURL(for: name)) { phase in
                switch phase {
                case .empty:
                    placeholderVehicle
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderVehicle
                @unknown default:
                    placeholderVehicle
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Text(name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            if let subtitle {
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.8))
            }

            if let data = viewModel.details(for: name), let original = data.originalPrice {
                Text("Price: \(data.formattedOriginalPrice)")
                    .font(.footnote)
                    .foregroundStyle(.green.opacity(0.9))
                    .accessibilityLabel("Original price \(original)")
            }
        }
    }

    private var placeholderVehicle: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .overlay {
                Image(systemName: "car.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.5))
            }
    }

    private func salvageSection(items: [SalvageYardRobbery]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Salvage Yard Robberies")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(items) { item in
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.type)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                        Text(item.vehicle)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.85))
                    }
                    Spacer()
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
            }
        }
    }

    private func discountsSection(items: [DiscountDisplayItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Discounts")
                .font(.headline)
                .foregroundStyle(.white)

            ForEach(items) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.vehicleName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(item.label)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.75))

                    if let vehicleData = item.vehicleData {
                        Text("Now: \(vehicleData.formattedDiscountedPrice)")
                            .font(.caption)
                            .foregroundStyle(.mint)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.white.opacity(0.07))
                )
            }
        }
    }
}
