import SwiftUI

struct RootView: View {
    @Environment(AuthService.self) private var auth

    var body: some View {
        switch auth.state {
        case .loading:
            ProgressView().controlSize(.large)
        case .signedOut:
            SignInView()
        case .signedIn(let profile):
            switch profile.role {
            case .player: PlayerTabView()
            case .coach:  CoachTabView()
            }
        }
    }
}
