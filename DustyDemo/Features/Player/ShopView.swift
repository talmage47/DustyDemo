import SwiftUI

struct ShopView: View {
    @Environment(AuthService.self) private var auth
    @State private var shop = ShopService()

    private var profile: UserProfile? {
        if case .signedIn(let p) = auth.state { return p } else { return nil }
    }

    private let columns = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            Group {
                if shop.isLoading && shop.products.isEmpty {
                    ProgressView().frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if shop.products.isEmpty {
                    ContentUnavailableView(
                        "No Products",
                        systemImage: "bag",
                        description: Text("The demo catalog will populate on first launch.")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(shop.products) { product in
                                NavigationLink {
                                    ProductDetailView(product: product, team: shop.team)
                                } label: {
                                    ProductCard(product: product, team: shop.team)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Shop")
            .task {
                if let teamID = profile?.teamID {
                    await shop.load(teamID: teamID)
                }
            }
        }
    }
}

private struct ProductCard: View {
    let product: Product
    let team: Team?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                (team.map { Color(hex: $0.primaryColorHex) } ?? Color.gray)
                    .opacity(0.15)
                Image(systemName: product.symbol)
                    .font(.system(size: 44))
                    .foregroundStyle(team.map { Color(hex: $0.primaryColorHex) } ?? Color.gray)
            }
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(product.name).font(.appHeadline)
            Text(product.basePriceCents.asDollarString)
                .font(.appCaption)
                .foregroundStyle(AppColors.textMuted)
        }
    }
}
