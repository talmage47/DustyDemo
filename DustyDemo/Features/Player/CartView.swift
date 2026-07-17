import SwiftUI

struct CartView: View {
    @Environment(CartService.self) private var cart
    @State private var showingCheckout = false

    var body: some View {
        NavigationStack {
            Group {
                if cart.isEmpty {
                    ContentUnavailableView(
                        "Your Cart is Empty",
                        systemImage: "bag",
                        description: Text("Add items from the Shop tab to see them here.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(cart.items) { item in
                                CartLineRow(item: item)
                            }
                            .onDelete { indexSet in
                                for i in indexSet { cart.remove(cart.items[i]) }
                            }
                        }

                        Section("Summary") {
                            SummaryRow(label: "Subtotal",  cents: cart.subtotalCents)
                            SummaryRow(label: "Tax (8%)", cents: cart.taxCents)
                            SummaryRow(label: "Total",     cents: cart.totalCents, isTotal: true)
                        }

                        Section {
                            Button {
                                showingCheckout = true
                            } label: {
                                Text("Checkout")
                                    .font(.appHeadline)
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.borderedProminent)
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                        }
                    }
                }
            }
            .navigationTitle("Cart")
            .sheet(isPresented: $showingCheckout) {
                CheckoutView()
            }
        }
    }
}

private struct CartLineRow: View {
    @Environment(CartService.self) private var cart
    let item: CartItem

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.product.symbol)
                .font(.title2)
                .frame(width: 44, height: 44)
                .background(AppColors.surface)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(item.product.name).font(.appHeadline)
                Text("Size \(item.size)")
                    .font(.appCaption)
                    .foregroundStyle(AppColors.textMuted)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.lineTotalCents.asDollarString).font(.appHeadline)
                Stepper("\(item.quantity)", value: Binding(
                    get: { item.quantity },
                    set: { cart.setQuantity(item, to: $0) }
                ), in: 0...10)
                .labelsHidden()
            }
        }
        .padding(.vertical, 4)
    }
}

private struct SummaryRow: View {
    let label: String
    let cents: Int
    var isTotal: Bool = false

    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .appHeadline : .appBody)
            Spacer()
            Text(cents.asDollarString)
                .font(isTotal ? .appHeadline : .appBody)
        }
    }
}
