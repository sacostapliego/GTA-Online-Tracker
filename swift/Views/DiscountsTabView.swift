import SwiftUI

private enum DiscountCardStyle {
    static let cardBackground = Color(red: 26 / 255, green: 26 / 255, blue: 26 / 255)
    static let badgeBackground = Color(red: 245 / 255, green: 194 / 255, blue: 150 / 255)
    static let saleGreen = Color(red: 134 / 255, green: 239 / 255, blue: 172 / 255)
    static let originalPriceGrey = Color.white.opacity(0.45)
}

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
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                discountImage(urlString: item.imageURL)
                    .aspectRatio(16 / 9, contentMode: .fill)
                    .frame(maxWidth: .infinity)
                    .clipped()

                if let badge = percentOffBadgeText(for: item.vehicleData) {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(DiscountCardStyle.badgeBackground)
                        .padding(10)
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text(item.vehicleName.uppercased())
                    .font(.system(size: 15, weight: .bold, design: .default))
                    .italic()
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let vehicleData = item.vehicleData {
                    HStack(alignment: .firstTextBaseline, spacing: 10) {
                        Text(vehicleData.formattedDiscountedPrice)
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundStyle(DiscountCardStyle.saleGreen)

                        if let original = vehicleData.originalPrice, original > 0, !vehicleData.isFree {
                            Text(vehicleData.formattedOriginalPrice)
                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                .foregroundStyle(DiscountCardStyle.originalPriceGrey)
                                .strikethrough(true, color: DiscountCardStyle.originalPriceGrey)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DiscountCardStyle.cardBackground)
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    @ViewBuilder
    private func discountImage(urlString: String) -> some View {
        AsyncImage(url: URL(string: urlString)) { phase in
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
    }

    private var discountPlaceholder: some View {
        Rectangle()
            .fill(Color.black.opacity(0.45))
            .overlay {
                Image(systemName: "tag.fill")
                    .font(.title)
                    .foregroundStyle(.white.opacity(0.35))
            }
    }

    /// Badge like `35% OFF` from API `discount_percent`, or derived from original vs discounted price.
    private func percentOffBadgeText(for data: VehicleData?) -> String? {
        guard let data else { return nil }
        if let p = data.discountPercent, p > 0 {
            return "\(p)% OFF"
        }
        if data.isFree, (data.originalPrice ?? 0) > 0 {
            return "100% OFF"
        }
        if let orig = data.originalPrice, orig > 0, let disc = data.discountedPrice, !data.isFree {
            let pct = Int(round(100.0 - Double(disc * 100) / Double(orig)))
            let clamped = max(1, min(99, pct))
            return "\(clamped)% OFF"
        }
        return nil
    }
}
