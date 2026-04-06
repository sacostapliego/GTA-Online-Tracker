import SwiftUI

struct DiscountsTabView: View {
    @ObservedObject var viewModel: DashboardViewModel

    var body: some View {
        ZStack {
            background
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView("Loading discounts...")
                    .tint(.white)
                    .foregroundStyle(.white)
            } else if let weekly = viewModel.weeklyUpdate {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        header(weekly: weekly)
                        discountsList(items: viewModel.discountItems())
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
        Color(red: 18.0 / 255.0, green: 18.0 / 255.0, blue: 18.0 / 255.0)
    }

    private func header(weekly: WeeklyUpdate) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Discounts")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .minimumScaleFactor(0.85)
                .lineLimit(2)

            Text(weekly.weekOf)
                .font(.subheadline)
                .foregroundStyle(Color.blue.opacity(0.9))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }

    private func discountsList(items: [DiscountDisplayItem]) -> some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                discountRow(item: item)
            }
        }
    }

    private func discountRow(item: DiscountDisplayItem) -> some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: URL(string: item.imageURL)) { phase in
                switch phase {
                case .empty:
                    discountPlaceholder
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    discountPlaceholder
                @unknown default:
                    discountPlaceholder
                }
            }
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 6) {
                Text(item.vehicleName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text(item.label)
                    .font(.caption)
                    .foregroundStyle(.blue)

                if let vehicleData = item.vehicleData {
                    HStack(spacing: 8) {
                        if let original = vehicleData.originalPrice {
                            Text(vehicleData.formattedOriginalPrice)
                                .font(.caption2)
                                .foregroundStyle(.red.opacity(0.9))
                                .strikethrough()
                        }
                        Text("Now: \(vehicleData.formattedDiscountedPrice)")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.blue)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.blue.opacity(0.35), lineWidth: 1)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.3))
                )
        )
    }

    private var discountPlaceholder: some View {
        RoundedRectangle(cornerRadius: 10, style: .continuous)
            .fill(Color.black.opacity(0.4))
            .overlay {
                Image(systemName: "tag.fill")
                    .font(.title2)
                    .foregroundStyle(.blue.opacity(0.5))
            }
    }
}
