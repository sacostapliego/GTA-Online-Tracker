import Foundation

struct VehicleData: Codable {
    let type: String
    let url: String
    let slug: String?
    let imageURL: String
    let originalPrice: Int?
    let discountedPrice: Int?
    let discountPercent: Int?
    let isFree: Bool
    let discount: String?

    enum CodingKeys: String, CodingKey {
        case type
        case url
        case slug
        case imageURL = "image_url"
        case originalPrice = "original_price"
        case discountedPrice = "discounted_price"
        case discountPercent = "discount_percent"
        case isFree = "is_free"
        case discount
    }

    var formattedOriginalPrice: String {
        guard let originalPrice else { return "N/A" }
        return Self.currencyFormatter.string(from: NSNumber(value: originalPrice)) ?? "N/A"
    }

    var formattedDiscountedPrice: String {
        if isFree {
            return "FREE"
        }
        guard let discountedPrice else { return "N/A" }
        return Self.currencyFormatter.string(from: NSNumber(value: discountedPrice)) ?? "N/A"
    }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

typealias VehicleDataResponse = [String: VehicleData]

struct DiscountDisplayItem: Identifiable {
    let id = UUID()
    let label: String
    let vehicleName: String
    let vehicleData: VehicleData?
}
