import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

@MainActor
class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    private let continuation: CheckedContinuation<UserModel, Error>
    private var currentNonce: String?

    init(continuation: CheckedContinuation<UserModel, Error>, nonce: String) {
        self.continuation = continuation
        self.currentNonce = nonce
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let idTokenData = appleIDCredential.identityToken,
              let idTokenString = String(data: idTokenData, encoding: .utf8),
              let nonce = currentNonce else {
            continuation.resume(throwing: AppError.authenticationError("Invalid Apple ID Token or Nonce"))
            return
        }

        let credential = OAuthProvider.credential(
            providerID: AuthProviderID.apple,
            idToken: idTokenString,
            rawNonce: nonce
        )

        Task {
            do {
                let authResult = try await SessionManager.shared.auth.signIn(with: credential)
                let userModel = UserModel(
                    uid: authResult.user.uid,
                    email: authResult.user.email,
                    fullName: appleIDCredential.fullName?.givenName ?? Constants.DefaultValues.defaultFullName,
                    profileImageUrl: nil
                )
                continuation.resume(returning: userModel)
                
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = authResult.user
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation.resume(throwing: error)
    }

    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.windows.first }
            .first ?? UIWindow()
    }
}
