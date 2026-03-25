import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn

@MainActor
final class AuthService: ObservableObject {
    static let shared = AuthService()

    @Published var currentUser: FirebaseAuth.User?
    @Published var isAuthenticated = false

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var cachedToken: String?
    private var tokenExpiry: Date?

    private init() {
        listenForAuthChanges()
    }

    private func listenForAuthChanges() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                if user == nil {
                    self?.cachedToken = nil
                    self?.tokenExpiry = nil
                }
            }
        }
    }

    func signInWithGoogle() async throws {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingIDToken
        }

        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )

        let authResult = try await Auth.auth().signIn(with: credential)
        self.currentUser = authResult.user
        self.isAuthenticated = true
    }

    func signOut() throws {
        try Auth.auth().signOut()
        GIDSignIn.sharedInstance.signOut()
        currentUser = nil
        isAuthenticated = false
        cachedToken = nil
        tokenExpiry = nil
    }

    func getIDToken() async -> String? {
        if let token = cachedToken, let expiry = tokenExpiry, expiry > Date().addingTimeInterval(60) {
            return token
        }

        guard let user = Auth.auth().currentUser else { return nil }

        do {
            let token = try await user.getIDToken()
            self.cachedToken = token
            self.tokenExpiry = Date().addingTimeInterval(3500)
            return token
        } catch {
            print("Failed to get ID token: \(error)")
            return nil
        }
    }
}

enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case missingIDToken

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Firebase client ID not found."
        case .noRootViewController:
            return "Unable to find root view controller."
        case .missingIDToken:
            return "Google sign-in did not return an ID token."
        }
    }
}
