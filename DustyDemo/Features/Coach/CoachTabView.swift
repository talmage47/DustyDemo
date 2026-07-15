import SwiftUI

struct CoachTabView: View {
    var body: some View {
        TabView {
            PlaceholderScreen(
                title: "Roster",
                systemImage: "list.bullet.rectangle.fill",
                message: "Your players, their sizes and numbers."
            )
            .tabItem { Label("Roster", systemImage: "list.bullet.rectangle.fill") }

            PlaceholderScreen(
                title: "Orders",
                systemImage: "checklist",
                message: "See who ordered, nudge who didn't."
            )
            .tabItem { Label("Orders", systemImage: "checklist") }

            PlaceholderScreen(
                title: "Designs",
                systemImage: "paintpalette.fill",
                message: "Your team's uniform designs."
            )
            .tabItem { Label("Designs", systemImage: "paintpalette.fill") }
        }
    }
}

#Preview {
    CoachTabView().environment(Session())
}
