import SwiftUI

struct MyTeamView: View {
    @Environment(AuthService.self) private var auth
    @State private var shop = ShopService()
    @State private var showingNumberEditor = false

    private var profile: UserProfile? {
        if case .signedIn(let p) = auth.state { return p } else { return nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    if let team = shop.team, let profile {
                        TeamDesignPreview(team: team, playerNumber: profile.playerNumber)
                            .padding(.horizontal)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(team.name).font(.appTitle)
                            Text("Football • Coached by \(team.coachName)")
                                .font(.appCaption)
                                .foregroundStyle(AppColors.textMuted)
                        }
                        .padding(.horizontal)

                        Divider().padding(.horizontal)

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Your Info").font(.appHeadline)

                            LabeledContent("Name", value: profile.displayName)
                            LabeledContent("Number") {
                                Button {
                                    showingNumberEditor = true
                                } label: {
                                    Text(profile.playerNumber.map { "#\($0)" } ?? "Tap to set")
                                        .foregroundStyle(profile.playerNumber == nil ? Color.accentColor : AppColors.textPrimary)
                                }
                            }
                            LabeledContent("Position", value: profile.playerPosition ?? "—")
                        }
                        .padding(.horizontal)
                    } else if shop.isLoading {
                        ProgressView().padding()
                    } else {
                        ContentUnavailableView(
                            "No Team Yet",
                            systemImage: "person.3",
                            description: Text("Sign out and back in to join the demo team.")
                        )
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("My Team")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") { auth.signOut() }
                }
            }
            .task {
                if let teamID = profile?.teamID {
                    await shop.load(teamID: teamID)
                }
            }
            .sheet(isPresented: $showingNumberEditor) {
                PlayerNumberEditor()
            }
        }
    }
}

private struct PlayerNumberEditor: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss
    @State private var numberText = ""
    @State private var position   = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Your Jersey") {
                    TextField("Number (1–99)", text: $numberText)
                        .keyboardType(.numberPad)
                    TextField("Position (optional)", text: $position)
                }
            }
            .navigationTitle("Update Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        Task {
                            let n = Int(numberText)
                            await auth.updateCurrentProfile { profile in
                                if let n, (1...99).contains(n) { profile.playerNumber = n }
                                let trimmed = position.trimmingCharacters(in: .whitespaces)
                                profile.playerPosition = trimmed.isEmpty ? nil : trimmed
                            }
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if case .signedIn(let p) = auth.state {
                    numberText = p.playerNumber.map(String.init) ?? ""
                    position   = p.playerPosition ?? ""
                }
            }
        }
    }
}
