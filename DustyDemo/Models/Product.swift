import Foundation

enum ProductCategory: String, Codable, CaseIterable, Identifiable {
    case jersey, pants, helmet, bag, accessory
    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .jersey:    "Jersey"
        case .pants:     "Pants"
        case .helmet:    "Helmet"
        case .bag:       "Bag"
        case .accessory: "Accessory"
        }
    }
}

struct Product: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var category: ProductCategory
    var symbol: String             // SF Symbol used as a stand-in for real imagery
    var basePriceCents: Int
    var availableSizes: [String]

    var basePriceDollars: Double { Double(basePriceCents) / 100 }
}
