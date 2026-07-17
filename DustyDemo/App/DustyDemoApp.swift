import SwiftUI
import FirebaseCore

@main
struct DustyDemoApp: App {
    @State private var auth: AuthService
    @State private var cart: CartService

    init() {
        FirebaseApp.configure()
        _auth = State(initialValue: AuthService())
        _cart = State(initialValue: CartService())

        // Fire-and-forget: ensure demo team + product catalog exist in Firestore.
        Task.detached { await SeedService.seedIfNeeded() }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(auth)
                .environment(cart)
        }
    }
}
