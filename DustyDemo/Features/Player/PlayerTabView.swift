import SwiftUI

struct PlayerTabView: View {
    var body: some View {
        TabView {
            PlaceholderScreen(
                title: "My Team",
                systemImage: "person.3.fill",
                message: "Your team's design, your size, your number."
            )
            .tabItem { Label("My Team", systemImage: "person.3.fill") }

            PlaceholderScreen(
                title: "Shop",
                systemImage: "bag.fill",
                message: "Order your uniform and gear."
            )
            .tabItem { Label("Shop", systemImage: "bag.fill") }

            PlaceholderScreen(
                title: "Orders",
                systemImage: "shippingbox.fill",
                message: "Track what you've ordered."
            )
            .tabItem { Label("Orders", systemImage: "shippingbox.fill") }
        }
    }
}

#Preview {
    PlayerTabView().environment(Session())
}
