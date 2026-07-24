import Foundation
import FirebaseFirestore

@Observable
@MainActor
final class RosterService {
    private(set) var players: [UserProfile] = []
    private(set) var isLoading = false
    private(set) var lastError: String?

    private let db = Firestore.firestore()

    func load(teamID: String) async {
        isLoading = true
        defer { isLoading = false }
        lastError = nil
        do {
            let snap = try await db.collection("users")
                .whereField("teamID", isEqualTo: teamID)
                .whereField("role", isEqualTo: UserRole.player.rawValue)
                .getDocuments()

            let loaded = snap.documents.compactMap { try? $0.data(as: UserProfile.self) }
            self.players = loaded.sorted {
                switch ($0.playerNumber, $1.playerNumber) {
                case let (a?, b?): return a < b
                case (_?, nil):    return true
                case (nil, _?):    return false
                default:           return $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending
                }
            }
        } catch {
            lastError = error.localizedDescription
        }
    }
}
