import SwiftUI

struct CoachTabView: View {
    var body: some View {
        TabView {
            RosterView()
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

