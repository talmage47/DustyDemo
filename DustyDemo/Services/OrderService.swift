import Foundation
import FirebaseFirestore

@Observable
@MainActor
final class OrderService {
    private(set) var orders: [Order] = []
    private(set) var isLoading = false
    private(set) var lastError: String?

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    /// Subscribe to the current player's orders in real time.
    func startListening(playerID: String) {
        listener?.remove()
        isLoading = true
        listener = db.collection("orders")
            .whereField("playerID", isEqualTo: playerID)
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                Task { @MainActor in
                    guard let self else { return }
                    self.isLoading = false
                    if let error {
                        self.lastError = error.localizedDescription
                        return
                    }
                    self.orders = snapshot?.documents.compactMap { try? $0.data(as: Order.self) } ?? []
                }
            }
    }

    func stopListening() {
        listener?.remove()
        listener = nil
    }

    /// Places an order from a cart. In Step 2c this will happen after Stripe
    /// confirms payment; for now the order is written directly as `.pending`.
    func placeOrder(from cart: CartService, player: UserProfile, team: Team) async throws {
        let items: [OrderLineItem] = cart.items.map { item in
            OrderLineItem(
                id: UUID().uuidString,
                productID: item.product.id,
                productName: item.product.name,
                category: item.product.category,
                size: item.size,
                quantity: item.quantity,
                unitPriceCents: item.product.basePriceCents,
                lineTotalCents: item.lineTotalCents
            )
        }
        let order = Order(
            id: UUID().uuidString,
            playerID: player.id,
            playerName: player.displayName,
            playerNumber: player.playerNumber,
            teamID: team.id,
            teamName: team.name,
            items: items,
            status: .pending,
            subtotalCents: cart.subtotalCents,
            taxCents: cart.taxCents,
            totalCents: cart.totalCents,
            createdAt: .now
        )
        try db.collection("orders").document(order.id).setData(from: order)
    }
}
