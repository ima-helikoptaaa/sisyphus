import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var animateTitle = false
    @State private var animateSubtitle = false
    @State private var animateButton = false

    var body: some View {
        ZStack {
            SisyphusTheme.background
                .ignoresSafeArea()

            // Subtle gradient overlay
            LinearGradient(
                colors: [
                    SisyphusTheme.accent.opacity(0.05),
                    Color.clear,
                    Color.clear
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo area
                VStack(spacing: 20) {
                    ZStack {
                        Circle()
                            .fill(SisyphusTheme.accent.opacity(0.1))
                            .frame(width: 100, height: 100)

                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 44))
                            .foregroundColor(SisyphusTheme.accent)
                    }
                    .offset(y: animateTitle ? 0 : -20)
                    .opacity(animateTitle ? 1 : 0)

                    VStack(spacing: 8) {
                        Text("SISYPHUS")
                            .font(.system(size: 42, weight: .black, design: .default))
                            .tracking(8)
                            .foregroundColor(SisyphusTheme.accent)
                            .offset(y: animateTitle ? 0 : 20)
                            .opacity(animateTitle ? 1 : 0)

                        Text("Push your limits. Every day.")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(SisyphusTheme.textSecondary)
                            .offset(y: animateSubtitle ? 0 : 15)
                            .opacity(animateSubtitle ? 1 : 0)
                    }
                }

                Spacer()

                // Sign in section
                VStack(spacing: 16) {
                    if let error = authViewModel.errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(SisyphusTheme.destructive)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .transition(.opacity)
                    }

                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 22))

                            Text("Continue with Google")
                                .font(.system(size: 17, weight: .semibold))
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(SisyphusTheme.accent)
                        .cornerRadius(SisyphusTheme.buttonRadius)
                    }
                    .disabled(authViewModel.isLoading)
                    .opacity(authViewModel.isLoading ? 0.7 : 1.0)
                    .overlay {
                        if authViewModel.isLoading {
                            ProgressView()
                                .tint(.black)
                        }
                    }
                    .offset(y: animateButton ? 0 : 30)
                    .opacity(animateButton ? 1 : 0)

                    Text("By continuing, you agree to our Terms of Service")
                        .font(.system(size: 12))
                        .foregroundColor(SisyphusTheme.textTertiary)
                        .multilineTextAlignment(.center)
                        .opacity(animateButton ? 1 : 0)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                animateTitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
                animateSubtitle = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                animateButton = true
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
