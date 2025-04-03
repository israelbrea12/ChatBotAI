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
        print("Llega aqui")
        let authResult = try await SessionManager.shared.auth.signIn(
            withEmail: email,
            password: password
        )
        print("Usuario autenticado con UID: \(authResult.user.uid)")

        do {
            let user = try await userDataSource.fetchUser()
            print("Usuario recuperado de Firebase Database: \(user)")
            return user
        } catch {
            print("Error al recuperar usuario de Firebase Database: \(error)")
            throw error
        }
    }
    
    func signUp(email: String, password: String, fullName: String, profileImage: UIImage?) async throws -> UserModel {
        print("DEBUG: Iniciando proceso de registro para \(email)")

        let authResult = try await SessionManager.shared.auth.createUser(
            withEmail: email,
            password: password
        )
        print(
            "DEBUG: Usuario de Firebase creado con UID: \(authResult.user.uid)"
        )

        var profileImageUrl: String? = nil

        if let image = profileImage {
            do {
                profileImageUrl = try await uploadProfileImage(
                    image: image,
                    userId: authResult.user.uid
                )
                print(
                    "DEBUG: Imagen subida con éxito: \(profileImageUrl ?? "")"
                )
            } catch {
                print(
                    "DEBUG: Error al subir la imagen: \(error.localizedDescription)"
                )
                throw AppError
                    .unknownError(
                        "Error al subir la imagen: \(error.localizedDescription)"
                    )
            }
        }

        let user = UserModel(
            uid: authResult.user.uid,
            email: email,
            fullName: fullName,
            profileImageUrl: profileImageUrl
        )

        let userValues: [String: Any] = [
            "uid": user.uid,
            "email": user.email ?? "",
            "fullName": user.fullName ?? "",
            "profileImageUrl": user.profileImageUrl ?? ""
        ]

        let ref = Database.database().reference().child("users").child(user.uid)

        do {
            try await ref.setValue(userValues)
            print("DEBUG: Usuario guardado en Realtime Database con éxito")
        } catch {
            print(
                "DEBUG: Error al guardar en Realtime Database: \(error.localizedDescription)"
            )
            throw AppError
                .unknownError(
                    "Error al guardar usuario en Realtime Database: \(error.localizedDescription)"
                )
        }

        return user
    }

    private func uploadProfileImage(image: UIImage, userId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            throw AppError
                .unknownError("No se pudo convertir la imagen a datos")
        }

        let storageRef = Storage.storage().reference().child(
            "profile_images/\(userId).jpg"
        )
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }


    
    func signOut() throws {
        try Auth.auth().signOut()
    }

    
    // MARK: - Sign In With Google
    
    func signInWithGoogle() async throws -> UserModel {
            switch await googleAuthService.signIn() {
            case .success(let authResult):
                let uid = authResult.user.uid
                let email = authResult.user.email ?? "No email"
                let fullName = authResult.user.displayName ?? email.components(separatedBy: "@").first ?? "Unknown"
                let profileImageUrl = authResult.user.photoURL?.absoluteString
                
                let userModel = UserModel(uid: uid, email: email, fullName: fullName, profileImageUrl: profileImageUrl)
                
                // Guardar usuario en Firebase Database si no existe
                let userRef = Database.database().reference().child("users").child(uid)
                do {
                    let snapshot = try await userRef.getData()
                    if !snapshot.exists() {
                        let userValues: [String: Any] = [
                            "uid": uid,
                            "email": email,
                            "fullName": fullName,
                            "profileImageUrl": profileImageUrl ?? ""
                        ]
                        try await userRef.setValue(userValues)
                    }
                } catch {
                    throw AppError.unknownError("Error log in google account: \(error.localizedDescription)")
                }
                
                DispatchQueue.main.async {
                    SessionManager.shared.userSession = authResult.user
                }
                
                return userModel
            case .failure(let error):
                throw AppError.unknownError("Error log in google account: \(error.localizedDescription)")
            }
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
}
