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
import UIKit

protocol UserDataSource {
    func fetchUser() async throws -> UserModel
    func fetchUsersByLanguage(learningLanguage: String) async throws -> [UserModel]
    func fetchUserById(userId: String) async throws -> UserModel
    func updateUserData(fullName: String?, profileImage: UIImage?, learningLanguage: String?) async throws -> UserModel
    func deleteUserData(userId: String) async throws
    func updateUserLearningLanguage(language: String) async throws
}

class UserDataSourceImpl: UserDataSource {
    
    func fetchUser() async throws -> UserModel {
        guard let uid = await SessionManager.shared.auth.currentUser?.uid else {
            throw AppError.authenticationError("Unauthorized")
        }
        let ref = Database.database().reference().child(Constants.Database.users).child(uid)
        let snapshot = try await ref.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            throw AppError.unknownError("Failed to fetch user")
        }
        
        return UserModel(
            uid: uid,
            email: data[Constants.Database.User.email] as? String,
            fullName: data[Constants.Database.User.fullName] as? String,
            profileImageUrl: data[Constants.Database.User.profileImageUrl] as? String,
            learningLanguage: data[Constants.Database.User.learningLanguage] as? String
        )
    }
    
    func fetchUsersByLanguage(learningLanguage: String) async throws -> [UserModel] {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            throw AppError.authenticationError("Unauthorized")
        }
        
        let ref = Database.database().reference().child(Constants.Database.users)
        
        let query = ref.queryOrdered(byChild: Constants.Database.User.learningLanguage).queryEqual(toValue: learningLanguage)
        
        let snapshot = try await query.getData()
        
        guard let usersData = snapshot.value as? [String: [String: Any]] else {
            return []
        }
        
        return usersData.compactMap { (key, value) -> UserModel? in
            guard key != currentUserID else { return nil }
            
            return UserModel(
                uid: key,
                email: value[Constants.Database.User.email] as? String,
                fullName: value[Constants.Database.User.fullName] as? String,
                profileImageUrl: value[Constants.Database.User.profileImageUrl] as? String,
                learningLanguage: value[Constants.Database.User.learningLanguage] as? String
            )
        }
    }
    
    func fetchUserById(userId: String) async throws -> UserModel {
        let ref = Database.database().reference().child(Constants.Database.users).child(userId)
        let snapshot = try await ref.getData()
        
        guard let data = snapshot.value as? [String: Any] else {
            throw AppError.unknownError("User not found")
        }
        
        return UserModel(
            uid: userId,
            email: data[Constants.Database.User.email] as? String,
            fullName: data[Constants.Database.User.fullName] as? String,
            profileImageUrl: data[Constants.Database.User.profileImageUrl] as? String,
            learningLanguage: data[Constants.Database.User.learningLanguage] as? String
        )
    }
    
    func updateUserData(fullName: String?, profileImage: UIImage?, learningLanguage: String?) async throws -> UserModel {
        guard let uid = await SessionManager.shared.auth.currentUser?.uid else {
            throw AppError.authenticationError("Unauthorized")
        }
        
        let userRef = Database.database().reference().child(Constants.Database.users).child(uid)
        var valuesToUpdate: [String: Any] = [:]
        
        if let newName = fullName, !newName.isEmpty {
            valuesToUpdate[Constants.Database.User.fullName] = newName
        }
        
        if let image = profileImage {
            let newImageUrl = try await uploadProfileImage(image: image, userId: uid)
            valuesToUpdate[Constants.Database.User.profileImageUrl] = newImageUrl
        }
        
        if let lang = learningLanguage {
            valuesToUpdate[Constants.Database.User.learningLanguage] = lang
        }
        
        if !valuesToUpdate.isEmpty {
            try await userRef.updateChildValues(valuesToUpdate)
        }
        
        return try await fetchUser()
    }
    
    func deleteUserData(userId: String) async throws {
        let ref = Database.database().reference().child(Constants.Database.users).child(userId)
        try await ref.removeValue()
        print("✅ Datos del usuario eliminados de /users/\(userId)")
    }
    
    private func uploadProfileImage(image: UIImage, userId: String) async throws -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.3) else {
            throw AppError.unknownError("No se pudo convertir la imagen a datos")
        }
        
        let storageRef = Storage.storage().reference().child("\(Constants.Storage.profileImages)/\(userId)\(Constants.Storage.imageExtension)")
        _ = try await storageRef.putDataAsync(imageData, metadata: nil)
        return try await storageRef.downloadURL().absoluteString
    }
    
    func updateUserLearningLanguage(language: String) async throws {
        guard let userId = await SessionManager.shared.userSession?.uid else {
            throw AppError.authenticationError("Unauthorized")
        }
        
        let ref = Database.database().reference().child(Constants.Database.users).child(userId)
        try await ref.updateChildValues([Constants.Database.User.learningLanguage: language])
        print("✅ Idioma de aprendizaje actualizado en Firebase para el usuario: \(userId)")
    }
}

