import SwiftUI

struct SignInView: View {
    @Environment(Session.self) private var session
    @State private var email = ""
    @State private var showRolePicker = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 8) {
                Image(systemName: "tshirt.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)
                Text("DustyDemo")
                    .font(.appLargeTitle)
                Text("Team uniforms, on your phone.")
                    .font(.appCaption)
                    .foregroundStyle(AppColors.textMuted)
            }

            Spacer()

            VStack(spacing: 12) {
                TextField("Email", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)

                Button {
                    showRolePicker = true
                } label: {
                    Text("Continue")
                        .font(.appHeadline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(email.isEmpty)
            }
            .padding(.horizontal)

            Text("Demo build — real auth in Step 2")
                .font(.caption2)
                .foregroundStyle(AppColors.textMuted)
                .padding(.bottom)
        }
        .padding()
        .confirmationDialog("Sign in as…", isPresented: $showRolePicker, titleVisibility: .visible) {
            ForEach(Session.Role.allCases) { role in
                Button(role.displayName) { session.signIn(as: role) }
            }
            Button("Cancel", role: .cancel) { }
        }
    }
}

#Preview {
    SignInView().environment(Session())
}
