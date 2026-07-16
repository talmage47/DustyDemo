import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
final class AuthService {
    enum State: Equatable {
        case loading           // launching, waiting to hear from Firebase Auth
        case signedOut
        case signedIn(UserProfile)
    }

    private(set) var state: State = .loading
    private(set) var lastError: String?

    private let auth  = Auth.auth()
    private let db    = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        // Firebase Auth persists sessions across launches. Listen for state
        // changes and resolve into a fully-hydrated UserProfile (Auth uid +
        // Firestore users/{uid} doc holds the role).
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self else { return }
            Task { @MainActor in
                await self.hydrate(from: firebaseUser)
            }
        }
    }

    // No deinit: AuthService is held in the app's WindowGroup environment for
    // the app's entire lifetime, so tearing down the listener is unnecessary.

    // MARK: - Public API

    func signIn(email: String, password: String) async {
        lastError = nil
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
            // authStateDidChange listener will hydrate state
        } catch {
            lastError = friendlyMessage(from: error)
        }
    }

    func signUp(email: String, password: String, displayName: String, role: UserRole) async {
        lastError = nil
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            let profile = UserProfile(
                id: result.user.uid,
                email: email,
                displayName: displayName,
                role: role
            )
            try db.collection("users").document(profile.id).setData(from: profile)
            // authStateDidChange listener will hydrate state from the new user
        } catch {
            lastError = friendlyMessage(from: error)
        }
    }

    func signOut() {
        lastError = nil
        do {
            try auth.signOut()
        } catch {
            lastError = friendlyMessage(from: error)
        }
    }

    // MARK: - Internal

    private func hydrate(from firebaseUser: FirebaseAuth.User?) async {
        guard let firebaseUser else {
            state = .signedOut
            return
        }
        do {
            let snap = try await db.collection("users").document(firebaseUser.uid).getDocument()
            if let profile = try? snap.data(as: UserProfile.self) {
                state = .signedIn(profile)
            } else {
                // Auth account exists but Firestore user doc is missing — treat as signed out
                // so the user can re-run sign-up. Shouldn't happen in normal flows.
                try? auth.signOut()
                state = .signedOut
                lastError = "Your account is missing a profile. Please sign up again."
            }
        } catch {
            state = .signedOut
            lastError = friendlyMessage(from: error)
        }
    }

    private func friendlyMessage(from error: Error) -> String {
        let ns = error as NSError
        if ns.domain == AuthErrorDomain, let code = AuthErrorCode(rawValue: ns.code) {
            switch code {
            case .invalidEmail:            return "That doesn't look like a valid email."
            case .weakPassword:            return "Password is too weak (use at least 6 characters)."
            case .emailAlreadyInUse:       return "An account already exists for that email."
            case .wrongPassword,
                 .invalidCredential:       return "Wrong email or password."
            case .userNotFound:            return "No account found for that email."
            case .networkError:            return "Network error. Check your connection and try again."
            default:                       return ns.localizedDescription
            }
        }
        return ns.localizedDescription
    }
}
