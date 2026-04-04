import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var weeklyUpdate: WeeklyUpdate?
    @Published var vehicleData: VehicleDataResponse = [:]
    @Published var gtaImages: GTAImageData = [:]
    @Published var propertyImages: PropertyImageData = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: TrackerAPI
    private let defaultImageURLString = "https://static.wikia.nocookie.net/gtawiki/images/5/50/GTAOnlineWebsite-ScreensPC-589-3840.jpg/revision/latest/scale-to-width-down/1000?cb=20210629175043"

    init(api: TrackerAPI = TrackerAPI()) {
        self.api = api
    }

    func load() async {
        isLoading = true
        errorMessage = nil

        do {
            async let weekly = api.fetchWeeklyUpdate()
            async let vehicles = api.fetchVehicleData()

            weeklyUpdate = try await weekly
            vehicleData = try await vehicles

            // Image map JSON is optional UI enrichment; failures here should not block weekly data.
            gtaImages = (try? await api.fetchGTAImageData()) ?? [:]
            propertyImages = (try? await api.fetchPropertyImageData()) ?? [:]
        } catch {
            errorMessage = "Unable to load tracker data. Check your backend endpoint or bundled sample files."
        }

        isLoading = false
    }

    func imageURL(for vehicleName: String) -> URL? {
        let resolvedURL = resolveImageURL(for: vehicleName)
        return URL(string: resolvedURL)
    }

    func details(for vehicleName: String) -> VehicleData? {
        vehicleData[vehicleName]
    }

    func discountItems() -> [DiscountDisplayItem] {
        guard let weeklyUpdate else {
            return []
        }

        var propertyImageCounter: [String: Int] = [:]

        return weeklyUpdate.discounts.compactMap { line in
            let components = line.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            guard components.count == 2 else {
                return nil
            }

            let discountName = components[1]
            let imageURL = resolveImageURL(for: discountName, propertyCounter: &propertyImageCounter)

            return DiscountDisplayItem(
                label: components[0],
                vehicleName: discountName,
                imageURL: imageURL,
                vehicleData: vehicleData[discountName]
            )
        }
    }

    func bonusItems() -> [BonusDisplayItem] {
        guard let weeklyUpdate else {
            return []
        }

        var propertyImageCounter: [String: Int] = [:]

        return weeklyUpdate.bonuses.enumerated().map { index, line in
            let parsed = Self.parseBonusLine(line)
            let imageURL = resolveImageURL(for: parsed.activityName, propertyCounter: &propertyImageCounter)
            return BonusDisplayItem(
                id: "\(index)-\(line)",
                activityName: parsed.activityName,
                rewardBadge: parsed.rewardBadge,
                imageURL: imageURL
            )
        }
    }

    /// Weekly bonus strings are shaped like `"2X GTA$ and RP - Activity name"` from the scraper.
    private static func parseBonusLine(_ line: String) -> (rewardBadge: String, activityName: String) {
        let separator = " - "
        guard let range = line.range(of: separator) else {
            return ("", line)
        }
        let badge = String(line[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        let activity = String(line[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        let hasMultiplier = badge.range(of: #"\d+X"#, options: .regularExpression) != nil
        if hasMultiplier, !activity.isEmpty {
            return (badge, activity)
        }
        return ("", line)
    }

    private func resolveImageURL(for text: String, propertyCounter: inout [String: Int]) -> String {
        if let vehicleImage = vehicleData[text]?.imageURL, !vehicleImage.isEmpty {
            return vehicleImage
        }

        if let gtaMatch = gtaImages.keys.first(where: { key in
            text.range(of: key, options: .caseInsensitive) != nil
        }) {
            let imageURL = gtaImages[gtaMatch]?.imageURL ?? ""
            if !imageURL.isEmpty, imageURL.uppercased() != "BLANK" {
                return imageURL
            }
        }

        if let propertyMatch = propertyImages.keys.first(where: { key in
            text.range(of: key, options: .caseInsensitive) != nil
        }), let propertyMap = propertyImages[propertyMatch] {
            propertyCounter[propertyMatch, default: 0] += 1
            let currentIndex = propertyCounter[propertyMatch] ?? 1
            let key = "image\(currentIndex)"
            if let matched = propertyMap[key], !matched.isEmpty {
                return matched
            }
            if let fallbackPropertyImage = propertyMap["image1"], !fallbackPropertyImage.isEmpty {
                return fallbackPropertyImage
            }
            if let firstDefined = propertyMap.keys.sorted().compactMap({ propertyMap[$0] }).first(where: { !$0.isEmpty }) {
                return firstDefined
            }
        }

        return defaultImageURLString
    }

    private func resolveImageURL(for text: String) -> String {
        var counter: [String: Int] = [:]
        return resolveImageURL(for: text, propertyCounter: &counter)
    }
}
