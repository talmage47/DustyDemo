import SwiftUI

/// Mock checkout — writes an Order to Firestore with status `.pending`.
/// Real Stripe integration lands in Step 2c.
struct CheckoutView: View {
    @Environment(AuthService.self)  private var auth
    @Environment(CartService.self)  private var cart
    @Environment(\.dismiss)         private var dismiss

    @State private var shop = ShopService()
    @State private var orderService = OrderService()
    @State private var isPlacing = false
    @State private var placedSuccessfully = false
    @State private var errorMessage: String?

    private var profile: UserProfile? {
        if case .signedIn(let p) = auth.state { return p } else { return nil }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Order Summary") {
                    ForEach(cart.items) { item in
                        HStack {
                            Text("\(item.quantity) × \(item.product.name) (\(item.size))")
                            Spacer()
                            Text(item.lineTotalCents.asDollarString)
                        }
                    }
                }

                Section {
                    HStack { Text("Subtotal");  Spacer(); Text(cart.subtotalCents.asDollarString) }
                    HStack { Text("Tax");        Spacer(); Text(cart.taxCents.asDollarString) }
                    HStack {
                        Text("Total").font(.appHeadline)
                        Spacer()
                        Text(cart.totalCents.asDollarString).font(.appHeadline)
                    }
                }

                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red) }
                }

                Section {
                    Button {
                        Task { await placeOrder() }
                    } label: {
                        if isPlacing {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Place Order (Payment coming in 2c)")
                                .font(.appHeadline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(isPlacing || cart.isEmpty)
                }
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Order Placed!", isPresented: $placedSuccessfully) {
                Button("Done") { dismiss() }
            } message: {
                Text("Check the Orders tab to see it. Payment will be wired up in Step 2c.")
            }
            .task {
                if let teamID = profile?.teamID { await shop.load(teamID: teamID) }
            }
        }
    }

    private func placeOrder() async {
        guard let profile, let team = shop.team else {
            errorMessage = "Team info hasn't loaded yet. Try again in a moment."
            return
        }
        isPlacing = true
        defer { isPlacing = false }
        do {
            try await orderService.placeOrder(from: cart, player: profile, team: team)
            cart.clear()
            placedSuccessfully = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
