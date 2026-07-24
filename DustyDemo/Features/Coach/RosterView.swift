import SwiftUI

struct RosterView: View {
    @Environment(AuthService.self) private var auth
    @State private var roster = RosterService()

    private var profile: UserProfile? {
        if case .signedIn(let p) = auth.state { return p } else { return nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if roster.isLoading && roster.players.isEmpty {
                    ProgressView().controlSize(.large)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if roster.players.isEmpty {
                    ContentUnavailableView(
                        "No Players Yet",
                        systemImage: "person.3",
                        description: Text("Once players sign up and join your team, they'll show up here.")
                    )
                } else {
                    List {
                        Section {
                            ForEach(roster.players) { player in
                                RosterRow(player: player)
                            }
                        } header: {
                            Text("\(roster.players.count) Player\(roster.players.count == 1 ? "" : "s")")
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Roster")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") { auth.signOut() }
                }
            }
            .task {
                if let teamID = profile?.teamID {
                    await roster.load(teamID: teamID)
                }
            }
            .refreshable {
                if let teamID = profile?.teamID {
                    await roster.load(teamID: teamID)
                }
            }
        }
    }
}

private struct RosterRow: View {
    let player: UserProfile

    var body: some View {
        HStack(spacing: 14) {
            NumberBadge(number: player.playerNumber)
            VStack(alignment: .leading, spacing: 2) {
                Text(player.displayName).font(.appHeadline)
                Text(player.playerPosition ?? "Position not set")
                    .font(.appCaption)
                    .foregroundStyle(AppColors.textMuted)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

private struct NumberBadge: View {
    let number: Int?

    var body: some View {
        ZStack {
            Circle()
                .fill(number == nil ? AppColors.surface : AppColors.accent.opacity(0.15))
                .frame(width: 44, height: 44)
            Text(number.map { "\($0)" } ?? "–")
                .font(.system(.headline, design: .rounded, weight: .bold))
                .foregroundStyle(number == nil ? AppColors.textMuted : AppColors.accent)
        }
    }
}
