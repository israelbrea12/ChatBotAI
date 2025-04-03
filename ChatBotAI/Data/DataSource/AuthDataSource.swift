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
    private var appleSignInDelegate: AppleSignInDelegate?
    
    init(userDataSource: UserDataSource) {
        self.userDataSource = userDataSource
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
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AppError.unknownError("Missing Google Client ID")
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = await windowScene.windows.first,
              let rootViewController = await window.rootViewController else {
            throw AppError.unknownError("No root view controller found")
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            guard let idToken = result.user.idToken?.tokenString else {
                throw AppError.authenticationError("Invalid ID Token")
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            let authResult = try await SessionManager.shared.auth.signIn(with: credential)

            let googleUser = result.user
            let email = googleUser.profile?.email ?? authResult.user.email
            let fullName = googleUser.profile?.name ?? email?.components(separatedBy: "@").first ?? "Unknown"
            let profileImageUrl = googleUser.profile?.imageURL(withDimension: 200)?.absoluteString

            let uid = authResult.user.uid

            print("DEBUG: Usuario autenticado con Google -> \(uid)")

            // Referencia a la base de datos
            let userRef = Database.database().reference().child("users").child(uid)

            // Verificar si el usuario ya está guardado en Firebase
            let snapshot = try await userRef.getData()
            if !snapshot.exists() {
                let userValues: [String: Any] = [
                    "uid": uid,
                    "email": email ?? "",
                    "fullName": fullName,
                    "profileImageUrl": profileImageUrl ?? ""
                ]

                do {
                    try await userRef.setValue(userValues)
                    print("DEBUG: Usuario guardado en Firebase Database con éxito")
                } catch {
                    print("DEBUG: Error al guardar usuario en Firebase Database: \(error.localizedDescription)")
                    throw AppError.unknownError("Error al guardar usuario en Firebase Database: \(error.localizedDescription)")
                }
            } else {
                print("DEBUG: Usuario ya existente en Firebase Database")
            }

            let userModel = UserModel(
                uid: uid,
                email: email,
                fullName: fullName,
                profileImageUrl: profileImageUrl
            )

            DispatchQueue.main.async {
                SessionManager.shared.userSession = authResult.user
            }

            return userModel
        } catch {
            throw AppError.unknownError("Error signing in with Google: \(error.localizedDescription)")
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
