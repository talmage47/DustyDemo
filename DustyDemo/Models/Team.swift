import Foundation

struct Team: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var sport: String              // "football" for the POC
    var primaryColorHex: String    // e.g. "#1B263B"
    var secondaryColorHex: String  // e.g. "#F4B942"
    var coachName: String
    var createdAt: Date
}
