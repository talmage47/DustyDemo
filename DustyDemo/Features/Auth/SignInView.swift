import SwiftUI

struct SignInView: View {
    @Environment(AuthService.self) private var auth
    @State private var email = ""
    @State private var password = ""
    @State private var showingSignUp = false
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
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
                        .autocorrectionDisabled()

                    SecureField("Password", text: $password)
                        .textFieldStyle(.roundedBorder)

                    if let error = auth.lastError {
                        Text(error)
                            .font(.appCaption)
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    Button {
                        Task {
                            isSubmitting = true
                            await auth.signIn(email: email, password: password)
                            isSubmitting = false
                        }
                    } label: {
                        if isSubmitting {
                            ProgressView().tint(.white)
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Sign In")
                                .font(.appHeadline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(!canSubmit || isSubmitting)

                    Button("Create an account") { showingSignUp = true }
                        .font(.appCaption)
                        .padding(.top, 4)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
            .sheet(isPresented: $showingSignUp) {
                SignUpView()
            }
        }
    }

    private var canSubmit: Bool {
        !email.isEmpty && password.count >= 6
    }
}
