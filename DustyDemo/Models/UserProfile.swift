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
    var id: String            // matches Firebase Auth uid
    var email: String
    var displayName: String
    var role: UserRole
    var createdAt: Date

    init(id: String, email: String, displayName: String, role: UserRole, createdAt: Date = .now) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.role = role
        self.createdAt = createdAt
    }
}
