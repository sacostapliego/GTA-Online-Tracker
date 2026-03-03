import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var weeklyUpdate: WeeklyUpdate?
    @Published var vehicleData: VehicleDataResponse = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let api: TrackerAPI

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
        } catch {
            errorMessage = "Unable to load tracker data. Check your backend endpoint or bundled sample files."
        }

        isLoading = false
    }

    func imageURL(for vehicleName: String) -> URL? {
        guard let path = vehicleData[vehicleName]?.imageURL else {
            return nil
        }
        return URL(string: path)
    }

    func details(for vehicleName: String) -> VehicleData? {
        vehicleData[vehicleName]
    }

    func discountItems() -> [DiscountDisplayItem] {
        guard let weeklyUpdate else {
            return []
        }

        return weeklyUpdate.discounts.compactMap { line in
            let components = line.split(separator: ":", maxSplits: 1).map { String($0).trimmingCharacters(in: .whitespaces) }
            guard components.count == 2 else {
                return nil
            }
            return DiscountDisplayItem(
                label: components[0],
                vehicleName: components[1],
                vehicleData: vehicleData[components[1]]
            )
        }
    }
}
