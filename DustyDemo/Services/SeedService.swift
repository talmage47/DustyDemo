import Foundation
import FirebaseFirestore

/// Ensures the hardcoded demo team and product catalog exist in Firestore.
/// For POC only — Step 3 replaces this with real team creation flow.
enum SeedService {
    static let demoTeamID = "ridgemont-wolverines"

    private static let demoTeam = Team(
        id: demoTeamID,
        name: "Ridgemont Wolverines",
        sport: "football",
        primaryColorHex: "#1B263B",   // navy
        secondaryColorHex: "#F4B942", // gold
        coachName: "Coach Delgado",
        createdAt: .now
    )

    private static let demoProducts: [Product] = [
        Product(id: "home-jersey",      name: "Home Jersey",       category: .jersey, symbol: "tshirt.fill",         basePriceCents: 7500,  availableSizes: ["YS","YM","YL","S","M","L","XL","XXL"]),
        Product(id: "away-jersey",      name: "Away Jersey",       category: .jersey, symbol: "tshirt",              basePriceCents: 7500,  availableSizes: ["YS","YM","YL","S","M","L","XL","XXL"]),
        Product(id: "practice-jersey",  name: "Practice Jersey",   category: .jersey, symbol: "tshirt.fill",         basePriceCents: 4500,  availableSizes: ["YS","YM","YL","S","M","L","XL","XXL"]),
        Product(id: "game-pants",       name: "Game Pants",        category: .pants,  symbol: "figure.american.football", basePriceCents: 6000, availableSizes: ["YS","YM","YL","S","M","L","XL","XXL"]),
        Product(id: "helmet",           name: "Helmet",            category: .helmet, symbol: "helmet.fill",         basePriceCents: 25000, availableSizes: ["S","M","L"]),
        Product(id: "duffel-bag",       name: "Team Duffel Bag",   category: .bag,    symbol: "bag.fill",            basePriceCents: 4500,  availableSizes: ["One Size"])
    ]

    /// Idempotent — safe to call every launch. Creates docs only if missing.
    static func seedIfNeeded() async {
        let db = Firestore.firestore()
        do {
            let teamRef = db.collection("teams").document(demoTeamID)
            let teamSnap = try await teamRef.getDocument()
            if !teamSnap.exists {
                try teamRef.setData(from: demoTeam)
            }
            for product in demoProducts {
                let ref = db.collection("products").document(product.id)
                let snap = try await ref.getDocument()
                if !snap.exists {
                    try ref.setData(from: product)
                }
            }
        } catch {
            print("SeedService failed: \(error.localizedDescription)")
        }
    }
}
