//
//  AuthDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit

protocol AuthDataSource {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String, fullName: String, profileImage: UIImage?) async throws -> UserModel
    func signOut() throws
    func fetchUser() async throws -> UserModel
    func fetchAllUsersExceptCurrent() async throws -> [UserModel]
}


class AuthDataSourceImpl: AuthDataSource {
    
    func signIn(email: String, password: String) async throws -> UserModel {
        print("Llega aqui")
        let authResult = try await SessionManager.shared.auth.signIn(
            withEmail: email,
            password: password
        )
        print("Usuario autenticado con UID: \(authResult.user.uid)")

        do {
            let user = try await fetchUser()
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
        print("DEBUG: Usuario de Firebase creado con UID: \(authResult.user.uid)")

        var profileImageUrl: String? = nil

        if let image = profileImage {
            do {
                profileImageUrl = try await uploadProfileImage(
                    image: image,
                    userId: authResult.user.uid
                )
                print("DEBUG: Imagen subida con éxito: \(profileImageUrl ?? "")")
            } catch {
                print("DEBUG: Error al subir la imagen: \(error.localizedDescription)")
                throw AppError.unknownError("Error al subir la imagen: \(error.localizedDescription)")
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
            print("DEBUG: Error al guardar en Realtime Database: \(error.localizedDescription)")
            throw AppError.unknownError("Error al guardar usuario en Realtime Database: \(error.localizedDescription)")
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

    
    func fetchUser() async throws -> UserModel {
        guard let uid = await SessionManager.shared.auth.currentUser?.uid else {
            throw AppError.authenticationError("Unauthorized")
        }
        let ref = Database.database().reference().child("users").child(uid)
        let snapshot = try await ref.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            throw AppError.unknownError("Failed to fetch user")
        }

        return UserModel(
            uid: uid,
            email: data["email"] as? String,
            fullName: data["fullName"] as? String,
            profileImageUrl: data["profileImageUrl"] as? String
        )
    }
    
    func fetchAllUsersExceptCurrent() async throws -> [UserModel] {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            throw AppError.authenticationError("Unauthorized")
        }

        let ref = Database.database().reference().child("users")
        let snapshot = try await ref.getData()
        
        guard let usersData = snapshot.value as? [String: [String: Any]] else {
            throw AppError.unknownError("Failed to fetch users")
        }

        return usersData.compactMap { (key, value) -> UserModel? in
            guard key != currentUserID else { return nil }
            return UserModel(
                uid: key,
                email: value["email"] as? String,
                fullName: value["fullName"] as? String,
                profileImageUrl: value["profileImageUrl"] as? String
            )
        }
    }

}
