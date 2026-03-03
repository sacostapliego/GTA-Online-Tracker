import Foundation

struct WeeklyUpdate: Codable {
    let weekOf: String
    let introMessages: [String]
    let podiumVehicle: String
    let prizeRideVehicle: String
    let prizeRideChallenge: String
    let timeTrial: String
    let premiumRace: String
    let hswTimeTrial: String
    let salvageYardRobberies: [SalvageYardRobbery]
    let weeklyChallenge: String
    let bonuses: [String]
    let discounts: [String]
}

struct SalvageYardRobbery: Codable, Identifiable {
    let type: String
    let vehicle: String

    var id: String { "\(type)-\(vehicle)" }
}
