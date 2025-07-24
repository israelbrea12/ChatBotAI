//
//  UserRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation
import UIKit

class UserRepositoryImpl: UserRepository {
    
    private let userDataSource: UserDataSource
    
    init(userDataSource: UserDataSource) {
        self.userDataSource = userDataSource
    }
    
    
    func fetchUser() async -> Result<User?, AppError> {
        do {
            let userModel = try await userDataSource.fetchUser()
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func fetchAllUsersExceptCurrent() async -> Result<[User?], AppError> {
        do {
            let users = try await userDataSource.fetchAllUsersExceptCurrent()
            return .success(users.map { $0.toDomain() })
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func fetchUserById(userId: String) async -> Result<User?, AppError> {
        do {
            let userModel = try await userDataSource.fetchUserById(userId: userId)
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func updateUserData(fullName: String?, profileImage: UIImage?) async -> Result<User, AppError> {
        do {
            let userModel = try await userDataSource.updateUserData(fullName: fullName, profileImage: profileImage)
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func deleteUserData(userId: String) async -> Result<Void, AppError> {
        do {
            try await userDataSource.deleteUserData(userId: userId)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func updateUserLearningLanguage(language: String) async -> Result<Void, AppError> {
        do {
            try await userDataSource.updateUserLearningLanguage(language: language)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
}
