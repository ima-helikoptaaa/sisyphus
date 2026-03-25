import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var user: FirebaseAuth.User?
    @Published var errorMessage: String?

    private let authService = AuthService.shared

    init() {
        observeAuthState()
    }

    private func observeAuthState() {
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.user = user
                self?.isAuthenticated = user != nil
            }
        }
    }

    func signInWithGoogle() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await authService.signInWithGoogle()
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
