import Foundation

enum TrackerAPIError: Error {
    case invalidBaseURL
    case invalidResponse
    case missingSampleData
}

final class TrackerAPI {
    private let session: URLSession
    private let baseURL: URL?

    init(baseURL: String = "", session: URLSession = .shared) {
        self.session = session
        if baseURL.isEmpty {
            self.baseURL = nil
        } else {
            self.baseURL = URL(string: baseURL)
        }
    }

    func fetchWeeklyUpdate() async throws -> WeeklyUpdate {
        if let baseURL {
            return try await fetchJSON(path: "weekly-update.json", from: baseURL)
        }
        return try loadSampleJSON(named: "weekly-update.sample", type: WeeklyUpdate.self)
    }

    func fetchVehicleData() async throws -> VehicleDataResponse {
        if let baseURL {
            return try await fetchJSON(path: "vehicle_data.json", from: baseURL)
        }
        return try loadSampleJSON(named: "vehicle-data.sample", type: VehicleDataResponse.self)
    }

    private func fetchJSON<T: Decodable>(path: String, from baseURL: URL) async throws -> T {
        let resolvedURL = baseURL.appendingPathComponent(path)
        let (data, response) = try await session.data(from: resolvedURL)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw TrackerAPIError.invalidResponse
        }
        return try JSONDecoder().decode(T.self, from: data)
    }

    private func loadSampleJSON<T: Decodable>(named resourceName: String, type: T.Type) throws -> T {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: "json") else {
            throw TrackerAPIError.missingSampleData
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(T.self, from: data)
    }
}
