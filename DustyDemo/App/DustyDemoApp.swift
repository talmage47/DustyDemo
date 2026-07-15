import SwiftUI

@main
struct DustyDemoApp: App {
    @State private var session = Session()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(session)
        }
    }
}

@Observable
final class Session {
    enum State {
        case signedOut
        case signedIn(role: Role)
    }

    enum Role: String, CaseIterable, Identifiable {
        case player, coach
        var id: String { rawValue }
        var displayName: String {
            switch self {
            case .player: "Player"
            case .coach:  "Coach"
            }
        }
    }

    var state: State = .signedOut

    func signIn(as role: Role) { state = .signedIn(role: role) }
    func signOut()             { state = .signedOut }
}
