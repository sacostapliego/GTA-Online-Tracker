import Foundation

enum TrackerAPIError: Error {
    case invalidBaseURL
    case invalidResponse
    case missingSampleData
}

struct GTAImageEntry: Codable {
    let imageURL: String

    enum CodingKeys: String, CodingKey {
        case imageURL
    }
}

typealias GTAImageData = [String: GTAImageEntry]
typealias PropertyImageData = [String: [String: String]]

final class TrackerAPI {
    private let session: URLSession
    private let baseURL: URL?

    /// Default base URL matches Expo's data source (GitHub raw content).
    private static let defaultBaseURL = "https://raw.githubusercontent.com/sacostapliego/GTA-Online-Tracker/refs/heads/main/Scraper/data"

    init(baseURL: String? = nil, session: URLSession = .shared) {
        self.session = session
        let urlString = (baseURL?.isEmpty == false) ? baseURL! : Self.defaultBaseURL
        self.baseURL = URL(string: urlString)
    }

    func fetchWeeklyUpdate() async throws -> WeeklyUpdate {
        if let baseURL {
            do {
                return try await fetchJSON(path: "weekly-update.json", from: baseURL)
            } catch {
                if let fallback = try? loadSampleJSON(named: "fallback", type: WeeklyUpdate.self) {
                    return fallback
                }
                return try loadSampleJSON(named: "weekly-update.sample", type: WeeklyUpdate.self)
            }
        }
        if let fallback = try? loadSampleJSON(named: "fallback", type: WeeklyUpdate.self) {
            return fallback
        }
        return try loadSampleJSON(named: "weekly-update.sample", type: WeeklyUpdate.self)
    }

    func fetchVehicleData() async throws -> VehicleDataResponse {
        if let baseURL {
            do {
                return try await fetchJSON(path: "vehicle_data.json", from: baseURL)
            } catch {
                return try loadSampleJSON(named: "vehicle-data.sample", type: VehicleDataResponse.self)
            }
        }
        return try loadSampleJSON(named: "vehicle-data.sample", type: VehicleDataResponse.self)
    }

    func fetchGTAImageData() async throws -> GTAImageData {
        return try loadSampleJSON(named: "gta_images", type: GTAImageData.self)
    }

    func fetchPropertyImageData() async throws -> PropertyImageData {
        return try loadSampleJSON(named: "property_images", type: PropertyImageData.self)
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
