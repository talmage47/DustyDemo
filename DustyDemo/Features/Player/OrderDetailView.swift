import SwiftUI

struct OrderDetailView: View {
    let order: Order

    var body: some View {
        List {
            Section("Status") {
                LabeledContent("Current") { Text(order.status.displayName) }
                LabeledContent("Placed") {
                    Text(order.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
            }

            Section("Team") {
                LabeledContent("Team",   value: order.teamName)
                LabeledContent("Player", value: order.playerName)
                if let n = order.playerNumber {
                    LabeledContent("Number", value: "#\(n)")
                }
            }

            Section("Items") {
                ForEach(order.items) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.productName).font(.appHeadline)
                            Text("Size \(item.size) × \(item.quantity)")
                                .font(.appCaption)
                                .foregroundStyle(AppColors.textMuted)
                        }
                        Spacer()
                        Text(item.lineTotalCents.asDollarString)
                    }
                }
            }

            Section("Total") {
                HStack { Text("Subtotal"); Spacer(); Text(order.subtotalCents.asDollarString) }
                HStack { Text("Tax");       Spacer(); Text(order.taxCents.asDollarString) }
                HStack {
                    Text("Total").font(.appHeadline)
                    Spacer()
                    Text(order.totalCents.asDollarString).font(.appHeadline)
                }
            }
        }
        .navigationTitle("Order")
        .navigationBarTitleDisplayMode(.inline)
    }
}
