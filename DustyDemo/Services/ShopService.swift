import Foundation
import FirebaseFirestore

@Observable
@MainActor
final class ShopService {
    private(set) var team: Team?
    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var lastError: String?

    private let db = Firestore.firestore()

    func load(teamID: String) async {
        isLoading = true
        defer { isLoading = false }
        lastError = nil
        do {
            async let teamSnap    = db.collection("teams").document(teamID).getDocument()
            async let productSnap = db.collection("products").getDocuments()

            let (t, ps) = try await (teamSnap, productSnap)
            self.team = try? t.data(as: Team.self)
            self.products = ps.documents.compactMap { try? $0.data(as: Product.self) }
        } catch {
            lastError = error.localizedDescription
        }
    }
}
