import Foundation

enum UserRole: String, Codable, CaseIterable, Identifiable {
    case player, coach
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .player: "Player"
        case .coach:  "Coach"
        }
    }
}

struct UserProfile: Codable, Identifiable, Equatable {
    var id: String
    var email: String
    var displayName: String
    var role: UserRole
    var teamID: String?
    var playerNumber: Int?
    var playerPosition: String?
    var createdAt: Date

    init(
        id: String,
        email: String,
        displayName: String,
        role: UserRole,
        teamID: String? = nil,
        playerNumber: Int? = nil,
        playerPosition: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.teamID = teamID
        self.playerNumber = playerNumber
        self.playerPosition = playerPosition
        self.createdAt = createdAt
    }
}
