//
//  AuthRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation
import UIKit

class AuthRepositoryImpl: AuthRepository {
    
    private let dataSource: AuthDataSource
    
    init(dataSource: AuthDataSource) {
        self.dataSource = dataSource
    }
    
    func signIn(email: String, password: String) async -> Result<User, AppError> {
        do {
            let userModel = try await dataSource.signIn(email: email, password: password)
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func signUp(email: String, password: String, fullName: String, profileImage: UIImage?) async -> Result<User, AppError> {
        do {
            let userModel = try await dataSource.signUp(email: email, password: password, fullName: fullName, profileImage: profileImage)
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }

    
    func signOut() -> Result<Bool, AppError> {
        do {
            try dataSource.signOut()
            return .success(true)
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func signInWithGoogle() async -> Result<User, AppError> {
        do {
            let userModel = try await dataSource.signInWithGoogle()
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func signInWithApple() async -> Result<User, AppError> {
        do {
            let userModel = try await dataSource.signInWithApple()
            return .success(userModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func deleteFirebaseAuthUser() async -> Result<Void, AppError> {
        do {
            try await dataSource.deleteFirebaseAuthUser()
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func sendPasswordReset(email: String) async -> Result<Void, AppError> {
        do {
            try await dataSource.sendPasswordReset(email: email)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
}
