//
//  UserDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

protocol UserDataSource {
    func fetchUser() async throws -> UserModel
    func fetchAllUsersExceptCurrent() async throws -> [UserModel]
    func fetchUserById(userId: String) async throws -> UserModel
}


class UserDataSourceImpl: UserDataSource {
    
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
    
    func fetchUserById(userId: String) async throws -> UserModel {
            let ref = Database.database().reference().child("users").child(userId)
            let snapshot = try await ref.getData()
            
            guard let data = snapshot.value as? [String: Any] else {
                throw AppError.unknownError("User not found")
            }

            return UserModel(
                uid: userId,
                email: data["email"] as? String,
                fullName: data["fullName"] as? String,
                profileImageUrl: data["profileImageUrl"] as? String
            )
        }
}

