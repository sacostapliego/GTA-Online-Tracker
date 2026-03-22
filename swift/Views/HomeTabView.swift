import SwiftUI

struct HomeTabView: View {
    @ObservedObject var viewModel: DashboardViewModel

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
                    VStack(alignment: .leading, spacing: 24) {
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
                        timeTrialsSection(weekly: weekly)
                        salvageSection(items: weekly.salvageYardRobberies)
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

    private func titleHeader(weekly: WeeklyUpdate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("GTA Online Tracker")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)

            Text(weekly.weekOf)
                .font(.subheadline)
                .foregroundStyle(Color.orange.opacity(0.9))

            if let firstIntro = weekly.introMessages.first {
                Text(firstIntro)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.88))
                    .padding(.top, 4)
            }
        }
    }

    private func challengeCard(text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Weekly Challenge")
                .font(.headline)
                .foregroundStyle(.orange)

            Text(text)
                .foregroundStyle(.white.opacity(0.92))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.orange.opacity(0.4), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.3))
                )
        )
    }

    private func spotlightSection(title: String, name: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.orange)

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
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )

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
                    .foregroundStyle(.orange.opacity(0.95))
                    .accessibilityLabel("Original price \(original)")
            }
        }
    }

    private var placeholderVehicle: some View {
        Rectangle()
            .fill(Color.black.opacity(0.4))
            .overlay {
                Image(systemName: "car.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.orange.opacity(0.5))
            }
    }

    private func timeTrialsSection(weekly: WeeklyUpdate) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Time Trials")
                .font(.headline)
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                timeTrialRow(label: "Time Trial", value: weekly.timeTrial)
                timeTrialRow(label: "HSW Time Trial", value: weekly.hswTimeTrial)
            }
        }
    }

    private func timeTrialRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.25))
                )
        )
    }

    private func salvageSection(items: [SalvageYardRobbery]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Salvage Yard Robberies")
                .font(.headline)
                .foregroundStyle(.orange)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 14) {
                    ForEach(items) { item in
                        AsyncImage(url: viewModel.imageURL(for: item.vehicle)) { phase in
                            switch phase {
                            case .empty:
                                salvagePlaceholder
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                            case .failure:
                                salvagePlaceholder
                            @unknown default:
                                salvagePlaceholder
                            }
                        }
                        .frame(width: 290, height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(alignment: .bottomLeading) {
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.72)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            .overlay(alignment: .bottomLeading) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.type)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.white)
                                    Text(item.vehicle)
                                        .font(.footnote)
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                .padding(12)
                            }
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal, 1)
            }
            .frame(height: 180)
            .scrollClipDisabled()
        }
    }

    private var salvagePlaceholder: some View {
        Rectangle()
            .fill(Color.black.opacity(0.4))
            .overlay {
                Image(systemName: "car.rear.and.tire.marks")
                    .font(.title2)
                    .foregroundStyle(.orange.opacity(0.6))
            }
    }
}
