import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .error

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    header

                    // Social Sign In
                    socialSignIn

                    // Divider
                    divider

                    // Email/Password Form
                    emailPasswordForm

                    // Forgot Password
                    forgotPassword

                    // Sign In Button
                    signInButton

                    // Sign Up Link
                    signUpLink
                }
                .padding(Theme.Spacing.screenPadding)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Welcome Back")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toast(isPresented: $showToast, message: toastMessage, type: toastType)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "tshirt.fill")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.primary)

            Text("Sign in to your account")
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.top, Theme.Spacing.lg)
    }

    // MARK: - Social Sign In

    private var socialSignIn: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Sign in with Apple
            SignInWithAppleButton(.signIn) { request in
                authViewModel.handleSignInWithApple(request)
            } onCompletion: { result in
                handleSignInWithAppleResult(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: Theme.Layout.minTouchTarget)
            .cornerRadius(Theme.CornerRadius.sm)

            // Sign in with Google
            Button(action: {
                Task {
                    await signInWithGoogle()
                }
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)

                    Text("Continue with Google")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Layout.minTouchTarget)
            }
            .secondaryButtonStyle()
        }
    }

    // MARK: - Divider

    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Theme.Colors.border)
                .frame(height: 1)

            Text("or")
                .font(Theme.Typography.bodySmall)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.sm)

            Rectangle()
                .fill(Theme.Colors.border)
                .frame(height: 1)
        }
    }

    // MARK: - Email/Password Form

    private var emailPasswordForm: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Email Field
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Email")
                    .font(Theme.Typography.titleSmall)
                    .foregroundColor(Theme.Colors.text)

                TextField("Enter your email", text: $email)
                    .keyboardType(.emailAddress)
                    .textContentType(.emailAddress)
                    .autocapitalization(.none)
                    .padding(Theme.Spacing.md)
                    .background(Theme.Colors.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                            .stroke(Theme.Colors.border, lineWidth: 1)
                    )
                    .cornerRadius(Theme.CornerRadius.sm)
            }

            // Password Field
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("Password")
                    .font(Theme.Typography.titleSmall)
                    .foregroundColor(Theme.Colors.text)

                HStack {
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .textContentType(.password)
                    } else {
                        SecureField("Enter your password", text: $password)
                            .textContentType(.password)
                    }

                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(Theme.Colors.textSecondary)
                    }
                }
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
                .cornerRadius(Theme.CornerRadius.sm)
            }
        }
    }

    // MARK: - Forgot Password

    private var forgotPassword: some View {
        HStack {
            Spacer()
            NavigationLink(destination: ForgotPasswordView()) {
                Text("Forgot password?")
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
    }

    // MARK: - Sign In Button

    private var signInButton: some View {
        Button(action: {
            Task {
                await signIn()
            }
        }) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Sign In")
                    .fontWeight(.semibold)
            }
        }
        .primaryButtonStyle(isEnabled: !email.isEmpty && !password.isEmpty, isLoading: isLoading)
        .disabled(email.isEmpty || password.isEmpty || isLoading)
    }

    // MARK: - Sign Up Link

    private var signUpLink: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.textSecondary)

            NavigationLink(destination: RegisterView()) {
                Text("Sign up")
                    .font(Theme.Typography.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
    }

    // MARK: - Actions

    private func signIn() async {
        isLoading = true
        defer { isLoading = false }

        do {
            try await authViewModel.login(email: email, password: password)
            dismiss()
        } catch {
            toastMessage = error.localizedDescription
            toastType = .error
            showToast = true
        }
    }

    private func signInWithGoogle() async {
        do {
            try await authViewModel.loginWithGoogle()
            dismiss()
        } catch {
            toastMessage = error.localizedDescription
            toastType = .error
            showToast = true
        }
    }

    private func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            authViewModel.handleSignInWithAppleCompletion(authorization)
            dismiss()
        case .failure(let error):
            toastMessage = error.localizedDescription
            toastType = .error
            showToast = true
        }
    }
}

// MARK: - Register View

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var isLoading = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastView.ToastType = .error

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: Theme.Spacing.xl) {
                    // Header
                    header

                    // Social Sign Up
                    socialSignUp

                    // Divider
                    divider

                    // Registration Form
                    registrationForm

                    // Sign Up Button
                    signUpButton

                    // Sign In Link
                    signInLink
                }
                .padding(Theme.Spacing.screenPadding)
            }
            .background(Theme.Colors.background)
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .toast(isPresented: $showToast, message: toastMessage, type: toastType)
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "person.crop.circle.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(Theme.Colors.primary)

            Text("Join Stolen Tee today")
                .font(Theme.Typography.bodyLarge)
                .foregroundColor(Theme.Colors.textSecondary)
        }
        .padding(.top, Theme.Spacing.lg)
    }

    // MARK: - Social Sign Up

    private var socialSignUp: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Sign up with Apple
            SignInWithAppleButton(.signUp) { request in
                authViewModel.handleSignInWithApple(request)
            } onCompletion: { result in
                handleSignUpWithAppleResult(result)
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: Theme.Layout.minTouchTarget)
            .cornerRadius(Theme.CornerRadius.sm)

            // Sign up with Google
            Button(action: {
                Task {
                    await signUpWithGoogle()
                }
            }) {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .font(.title3)

                    Text("Continue with Google")
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: Theme.Layout.minTouchTarget)
            }
            .secondaryButtonStyle()
        }
    }

    // MARK: - Divider

    private var divider: some View {
        HStack {
            Rectangle()
                .fill(Theme.Colors.border)
                .frame(height: 1)

            Text("or")
                .font(Theme.Typography.bodySmall)
                .foregroundColor(Theme.Colors.textSecondary)
                .padding(.horizontal, Theme.Spacing.sm)

            Rectangle()
                .fill(Theme.Colors.border)
                .frame(height: 1)
        }
    }

    // MARK: - Registration Form

    private var registrationForm: some View {
        VStack(spacing: Theme.Spacing.md) {
            // Name Field
            FormField(title: "Name", text: $name, placeholder: "Enter your name")
                .textContentType(.name)

            // Email Field
            FormField(title: "Email", text: $email, placeholder: "Enter your email")
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)

            // Password Field
            SecureFormField(title: "Password", text: $password, showPassword: $showPassword, placeholder: "Create a password")

            // Confirm Password Field
            SecureFormField(title: "Confirm Password", text: $confirmPassword, showPassword: $showPassword, placeholder: "Confirm your password")
        }
    }

    // MARK: - Sign Up Button

    private var signUpButton: some View {
        Button(action: {
            Task {
                await signUp()
            }
        }) {
            if isLoading {
                ProgressView()
                    .tint(.white)
            } else {
                Text("Create Account")
                    .fontWeight(.semibold)
            }
        }
        .primaryButtonStyle(isEnabled: isFormValid, isLoading: isLoading)
        .disabled(!isFormValid || isLoading)
    }

    // MARK: - Sign In Link

    private var signInLink: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .font(Theme.Typography.bodyMedium)
                .foregroundColor(Theme.Colors.textSecondary)

            NavigationLink(destination: LoginView()) {
                Text("Sign in")
                    .font(Theme.Typography.bodyMedium)
                    .fontWeight(.semibold)
                    .foregroundColor(Theme.Colors.accent)
            }
        }
    }

    // MARK: - Validation

    private var isFormValid: Bool {
        !name.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 8
    }

    // MARK: - Actions

    private func signUp() async {
        guard password == confirmPassword else {
            toastMessage = "Passwords don't match"
            toastType = .error
            showToast = true
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            try await authViewModel.register(name: name, email: email, password: password)
            dismiss()
        } catch {
            toastMessage = error.localizedDescription
            toastType = .error
            showToast = true
        }
    }

    private func signUpWithGoogle() async {
        do {
            try await authViewModel.loginWithGoogle()
            dismiss()
        } catch {
            toastMessage = error.localizedDescription
            toastType = .error
            showToast = true
        }
    }

    private func handleSignUpWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            authViewModel.handleSignInWithAppleCompletion(authorization)
            dismiss()
        case .failure(let error):
            toastMessage = error.localizedDescription
            toastType = .error
            showToast = true
        }
    }
}

// MARK: - Form Field Components

struct FormField: View {
    let title: String
    @Binding var text: String
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.titleSmall)
                .foregroundColor(Theme.Colors.text)

            TextField(placeholder, text: $text)
                .padding(Theme.Spacing.md)
                .background(Theme.Colors.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                        .stroke(Theme.Colors.border, lineWidth: 1)
                )
                .cornerRadius(Theme.CornerRadius.sm)
        }
    }
}

struct SecureFormField: View {
    let title: String
    @Binding var text: String
    @Binding var showPassword: Bool
    let placeholder: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.titleSmall)
                .foregroundColor(Theme.Colors.text)

            HStack {
                if showPassword {
                    TextField(placeholder, text: $text)
                } else {
                    SecureField(placeholder, text: $text)
                }

                Button(action: {
                    showPassword.toggle()
                }) {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .foregroundColor(Theme.Colors.textSecondary)
                }
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.surface)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.CornerRadius.sm)
                    .stroke(Theme.Colors.border, lineWidth: 1)
            )
            .cornerRadius(Theme.CornerRadius.sm)
        }
    }
}

// MARK: - Forgot Password View

struct ForgotPasswordView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var showSuccessMessage = false

    var body: some View {
        VStack(spacing: Theme.Spacing.xl) {
            VStack(spacing: Theme.Spacing.md) {
                Image(systemName: "key.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Theme.Colors.accent)

                Text("Reset your password")
                    .font(Theme.Typography.headlineSmall)

                Text("Enter your email and we'll send you a link to reset your password")
                    .font(Theme.Typography.bodyMedium)
                    .foregroundColor(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, Theme.Spacing.xl)

            if !showSuccessMessage {
                VStack(spacing: Theme.Spacing.md) {
                    FormField(title: "Email", text: $email, placeholder: "Enter your email")
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)

                    Button(action: {
                        Task {
                            await resetPassword()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Send Reset Link")
                                .fontWeight(.semibold)
                        }
                    }
                    .primaryButtonStyle(isEnabled: !email.isEmpty, isLoading: isLoading)
                    .disabled(email.isEmpty || isLoading)
                }
            } else {
                VStack(spacing: Theme.Spacing.md) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(Theme.Colors.success)

                    Text("Check your email")
                        .font(Theme.Typography.headlineSmall)

                    Text("We've sent a password reset link to \(email)")
                        .font(Theme.Typography.bodyMedium)
                        .foregroundColor(Theme.Colors.textSecondary)
                        .multilineTextAlignment(.center)

                    Button("Done") {
                        dismiss()
                    }
                    .primaryButtonStyle()
                    .padding(.top, Theme.Spacing.md)
                }
            }

            Spacer()
        }
        .padding(Theme.Spacing.screenPadding)
        .navigationTitle("Forgot Password")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func resetPassword() async {
        isLoading = true
        // Simulate API call
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isLoading = false
        showSuccessMessage = true
    }
}

#Preview("Login") {
    LoginView()
        .environmentObject(AuthViewModel())
}

#Preview("Register") {
    RegisterView()
        .environmentObject(AuthViewModel())
}
