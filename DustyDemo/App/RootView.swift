import SwiftUI

struct RootView: View {
    @Environment(Session.self) private var session

    var body: some View {
        switch session.state {
        case .signedOut:
            SignInView()
        case .signedIn(role: .player):
            PlayerTabView()
        case .signedIn(role: .coach):
            CoachTabView()
        }
    }
}

#Preview("Signed out") {
    RootView().environment(Session())
}

#Preview("Player") {
    let s = Session(); s.signIn(as: .player)
    return RootView().environment(s)
}

#Preview("Coach") {
    let s = Session(); s.signIn(as: .coach)
    return RootView().environment(s)
}
