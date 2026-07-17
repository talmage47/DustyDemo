import Foundation

enum OrderStatus: String, Codable {
    case pending      // placed, not yet paid
    case paid
    case inProduction
    case shipped
    case delivered
    case canceled

    var displayName: String {
        switch self {
        case .pending:       "Awaiting Payment"
        case .paid:          "Paid"
        case .inProduction:  "In Production"
        case .shipped:       "Shipped"
        case .delivered:     "Delivered"
        case .canceled:      "Canceled"
        }
    }
}

struct OrderLineItem: Codable, Identifiable, Equatable {
    var id: String                 // client-generated UUID
    var productID: String
    var productName: String
    var category: ProductCategory
    var size: String
    var quantity: Int
    var unitPriceCents: Int
    var lineTotalCents: Int
}

struct Order: Codable, Identifiable, Equatable {
    var id: String                 // client-generated UUID; used as Firestore doc id
    var playerID: String
    var playerName: String
    var playerNumber: Int?
    var teamID: String
    var teamName: String
    var items: [OrderLineItem]
    var status: OrderStatus
    var subtotalCents: Int
    var taxCents: Int
    var totalCents: Int
    var createdAt: Date
}

extension Int {
    /// Format a cents value as `$XX.XX`
    var asDollarString: String {
        String(format: "$%.2f", Double(self) / 100)
    }
}
