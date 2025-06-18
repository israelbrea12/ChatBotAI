//
//  AuthDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation
@preconcurrency import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore
import AuthenticationServices

protocol AuthDataSource {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String, fullName: String, profileImage: UIImage?) async throws -> UserModel
    func signOut() throws
    func signInWithGoogle() async throws -> UserModel
    func signInWithApple() async throws -> UserModel
    func deleteAccount() async throws
}


class AuthDataSourceImpl: AuthDataSource {
    
    private let userDataSource: UserDataSource
    private let googleAuthService: GoogleAuthService
    private var appleSignInDelegate: AppleSignInDelegate?
    
    init(userDataSource: UserDataSource, googleAuthService: GoogleAuthService) {
        self.userDataSource = userDataSource
        self.googleAuthService = googleAuthService
    }
    
    func signIn(email: String, password: String) async throws -> UserModel {
        _ = try await SessionManager.shared.auth.signIn(
            withEmail: email,
            password: password
        )
        do {
            let user = try await userDataSource.fetchUser()
            return user
        } catch {
            throw error
        }
    }
    
    func signUp(email: String, password: String, fullName: String, profileImage: UIImage?) async throws -> UserModel {
            let authResult = try await SessionManager.shared.auth.createUser(withEmail: email, password: password)
            let uid = authResult.user.uid // Usa una constante para mayor claridad y brevedad

            var profileImageUrl: String? = nil
            if let image = profileImage {
                profileImageUrl = try await uploadProfileImage(image: image, userId: uid)
            }

            let userModel = UserModel(
                uid: uid,
                email: email,
                fullName: fullName,
                profileImageUrl: profileImageUrl
            )
            let userValues = userModel.toDictionary()

            let userRef = Database.database().reference().child("users").child(uid)
            try await userRef.setValue(userValues)

            return userModel
        }

    private func uploadProfileImage(image: UIImage, userId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            throw AppError.unknownError("No se pudo convertir la imagen a datos")
        }

        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }


    
    func signOut() throws {
        try Auth.auth().signOut()
    }

    
    // MARK: - Sign In With Google
    
    func signInWithGoogle() async throws -> UserModel {
        
        let authResult = try await googleAuthService.signIn().get()
        
        let uid = authResult.user.uid
        let email = authResult.user.email ?? "No email"
        let fullName = authResult.user.displayName ?? email.components(separatedBy: "@").first ?? "Unknown"
        let profileImageUrl = authResult.user.photoURL?.absoluteString
        
        let userModel = UserModel(uid: uid, email: email, fullName: fullName, profileImageUrl: profileImageUrl)
        
        try await saveUserIfNeeded(userModel)
        
        DispatchQueue.main.async {
            SessionManager.shared.userSession = authResult.user
        }
        
        return userModel
    }
    
    // MARK: - Sign In With Apple
    func signInWithApple() async throws -> UserModel {
        let nonce = CryptoUtils.randomNonceString()
        let hashedNonce = CryptoUtils.sha256(nonce)
        
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                let request = ASAuthorizationAppleIDProvider().createRequest()
                request.requestedScopes = [.fullName, .email]
                request.nonce = hashedNonce
                
                let delegate = AppleSignInDelegate(continuation: continuation, nonce: nonce)
                self.appleSignInDelegate = delegate // Guardamos la referencia para evitar que se libere
                
                let controller = ASAuthorizationController(authorizationRequests: [request])
                controller.delegate = delegate
                controller.presentationContextProvider = delegate
                controller.performRequests()
            }
        }
    }

    
    // MARK: - Delete Account
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AppError.authenticationError("No user logged in")
        }
        
        let userRef = Database.database().reference().child("users").child(user.uid)
        
        do {
            try await userRef.removeValue()
            try await user.delete()
        } catch {
            throw AppError.unknownError("Error deleting account: \(error.localizedDescription)")
        }
    }
    
    private func saveUserIfNeeded(_ userModel: UserModel) async throws {
        let userRef = Database.database().reference().child("users").child(userModel.uid)
        let snapshot = try await userRef.getData()
        if !snapshot.exists() {
            try await userRef.setValue(userModel.toDictionary())
        }
    }
}
