import Foundation
import FirebaseAuth
import FirebaseFirestore

@Observable
@MainActor
final class AuthService {
    enum State: Equatable {
        case loading
        case signedOut
        case signedIn(UserProfile)
    }

    private(set) var state: State = .loading
    private(set) var lastError: String?

    private let auth = Auth.auth()
    private let db   = Firestore.firestore()
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateHandle = auth.addStateDidChangeListener { [weak self] _, firebaseUser in
            guard let self else { return }
            Task { @MainActor in
                await self.hydrate(from: firebaseUser)
            }
        }
    }

    // MARK: - Public API

    func signIn(email: String, password: String) async {
        lastError = nil
        do {
            _ = try await auth.signIn(withEmail: email, password: password)
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
                role: role,
                teamID: SeedService.demoTeamID  // POC: everyone joins the demo team
            )
            try db.collection("users").document(profile.id).setData(from: profile)
        } catch {
            lastError = friendlyMessage(from: error)
        }
    }

    func signOut() {
        lastError = nil
        do { try auth.signOut() }
        catch { lastError = friendlyMessage(from: error) }
    }

    /// Persist a mutation to the current user's profile doc, and update local state.
    func updateCurrentProfile(_ mutate: (inout UserProfile) -> Void) async {
        guard case .signedIn(var profile) = state else { return }
        mutate(&profile)
        do {
            try db.collection("users").document(profile.id).setData(from: profile)
            state = .signedIn(profile)
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
            let docRef = db.collection("users").document(firebaseUser.uid)
            let snap = try await docRef.getDocument()
            guard var profile = try? snap.data(as: UserProfile.self) else {
                try? auth.signOut()
                state = .signedOut
                lastError = "Your account is missing a profile. Please sign up again."
                return
            }
            // Legacy safety net: users created before teamID existed get auto-joined.
            if profile.teamID == nil {
                profile.teamID = SeedService.demoTeamID
                try docRef.setData(from: profile)
            }
            state = .signedIn(profile)
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
