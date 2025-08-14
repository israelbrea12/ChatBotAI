//
//  GoogleAuthService.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore
import UIKit

protocol GoogleAuthService {
    func signIn() async -> Result<AuthDataResult, AppError>
}

class GoogleAuthServiceImpl: GoogleAuthService {
    func signIn() async -> Result<AuthDataResult, AppError> {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            return .failure(.unknownError("Missing Google Client ID"))
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        do {
            let result = try await signInOnMainThread()
            guard let idToken = result.user.idToken?.tokenString else {
                return .failure(.authenticationError("Invalid ID Token"))
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await SessionManager.shared.auth.signIn(with: credential)
            return .success(authResult)
        } catch {
            return .failure(.unknownError("Error signing in with Google: \(error.localizedDescription)"))
        }
    }
    
    @MainActor
    private func signInOnMainThread() async throws -> GIDSignInResult {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AppError.unknownError("No root view controller found")
        }
        
        return try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
    }
}
