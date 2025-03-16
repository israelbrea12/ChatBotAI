//
//  AuthDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

import Foundation

protocol AuthDataSource {
    func signIn(email: String, password: String) async throws -> UserModel
    func signUp(email: String, password: String, fullName: String) async throws -> UserModel
    func signOut() throws
    func fetchCurrentUser() async throws -> UserModel
}


class AuthDataSourceImpl: AuthDataSource {
    
    func signIn(email: String, password: String) async throws -> UserModel {
        print("Llega aqui")
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        print("Usuario autenticado con UID: \(authResult.user.uid)")

        do {
            let user = try await fetchUser(uid: authResult.user.uid)
            print("Usuario recuperado de Firestore: \(user)")
            return user
        } catch {
            print("Error al recuperar usuario de Firestore: \(error)")
            throw error
        }
    }
    
    func signUp(email: String, password: String, fullName: String) async throws -> UserModel {
        print("DEBUG: Iniciando proceso de registro para \(email)")
        
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        
        print("DEBUG: Usuario de Firebase creado con UID: \(authResult.user.uid)")
        
        let user = UserModel(uid: authResult.user.uid, email: email, fullName: fullName)
        let encodedUser = try Firestore.Encoder().encode(user)

        do {
            try await Firestore.firestore().collection("users").document(user.uid).setData(encodedUser)
            print("DEBUG: Usuario guardado en Firestore con éxito")
        } catch {
            print("DEBUG: Error al guardar en Firestore: \(error.localizedDescription)")
            throw AppError.unknownError("Error al guardar usuario en Firestore: \(error.localizedDescription)")
        }
        
        return user
    }

    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func fetchCurrentUser() async throws -> UserModel {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw AppError.unknownError("No user session found")
        }
        return try await fetchUser(uid: uid)
    }
    
    private func fetchUser(uid: String) async throws -> UserModel {
        let snapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
        guard let user = try? snapshot.data(as: UserModel.self) else {
            throw AppError.unknownError("Failed to fetch user")
        }
        print(user)
        return user
    }
}
