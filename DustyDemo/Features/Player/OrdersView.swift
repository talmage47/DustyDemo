import SwiftUI

struct OrdersView: View {
    @Environment(AuthService.self) private var auth
    @State private var orders = OrderService()

    private var profile: UserProfile? {
        if case .signedIn(let p) = auth.state { return p } else { return nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if orders.orders.isEmpty && !orders.isLoading {
                    ContentUnavailableView(
                        "No Orders Yet",
                        systemImage: "shippingbox",
                        description: Text("Once you place an order, it'll show up here.")
                    )
                } else {
                    List(orders.orders) { order in
                        NavigationLink {
                            OrderDetailView(order: order)
                        } label: {
                            OrderRow(order: order)
                        }
                    }
                }
            }
            .navigationTitle("Orders")
            .task {
                if let id = profile?.id { orders.startListening(playerID: id) }
            }
            .onDisappear { orders.stopListening() }
        }
    }
}

private struct OrderRow: View {
    let order: Order

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.appHeadline)
                Spacer()
                Text(order.totalCents.asDollarString).font(.appHeadline)
            }
            HStack {
                Text("\(order.items.reduce(0) { $0 + $1.quantity }) items")
                    .font(.appCaption)
                    .foregroundStyle(AppColors.textMuted)
                Spacer()
                StatusBadge(status: order.status)
            }
        }
        .padding(.vertical, 4)
    }
}

private struct StatusBadge: View {
    let status: OrderStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(tint.opacity(0.15))
            .foregroundStyle(tint)
            .clipShape(Capsule())
    }

    private var tint: Color {
        switch status {
        case .pending:      .orange
        case .paid:         .blue
        case .inProduction: .purple
        case .shipped:      .indigo
        case .delivered:    .green
        case .canceled:     .red
        }
    }
}
