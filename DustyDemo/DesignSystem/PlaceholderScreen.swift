import SwiftUI

struct PlaceholderScreen: View {
    let title: String
    let systemImage: String
    let message: String

    @Environment(Session.self) private var session

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: systemImage)
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)
                Text(message)
                    .font(.appBody)
                    .foregroundStyle(AppColors.textMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") { session.signOut() }
                }
            }
        }
    }
}
