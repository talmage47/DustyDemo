import SwiftUI

struct SignUpView: View {
    @Environment(AuthService.self) private var auth
    @Environment(\.dismiss) private var dismiss

    @State private var displayName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var role: UserRole = .player
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Account") {
                    TextField("Full name", text: $displayName)
                        .textContentType(.name)
                    TextField("Email", text: $email)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocorrectionDisabled()
                    SecureField("Password (6+ characters)", text: $password)
                        .textContentType(.newPassword)
                }

                Section("I am a…") {
                    Picker("Role", selection: $role) {
                        ForEach(UserRole.allCases) { role in
                            Text(role.displayName).tag(role)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                if let error = auth.lastError {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }

                Section {
                    Button {
                        Task {
                            isSubmitting = true
                            await auth.signUp(
                                email: email,
                                password: password,
                                displayName: displayName,
                                role: role
                            )
                            isSubmitting = false
                            // If sign-up succeeded, RootView will switch away automatically.
                            // Dismiss the sheet regardless — SignInView won't be visible
                            // if auth succeeded, so a leftover sheet is harmless.
                            if auth.lastError == nil { dismiss() }
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView().frame(maxWidth: .infinity)
                        } else {
                            Text("Create Account").frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!canSubmit || isSubmitting)
                }
            }
            .navigationTitle("Sign Up")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var canSubmit: Bool {
        !displayName.isEmpty && !email.isEmpty && password.count >= 6
    }
}

#Preview {
    SignUpView()
}
