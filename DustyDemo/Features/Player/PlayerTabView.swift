import SwiftUI

struct PlayerTabView: View {
    @Environment(CartService.self) private var cart

    var body: some View {
        TabView {
            MyTeamView()
                .tabItem { Label("My Team", systemImage: "person.3.fill") }

            ShopView()
                .tabItem { Label("Shop", systemImage: "bag.fill") }

            CartView()
                .tabItem { Label("Cart", systemImage: "cart.fill") }
                .badge(cart.itemCount)

            OrdersView()
                .tabItem { Label("Orders", systemImage: "shippingbox.fill") }
        }
    }
}
