//
//  UserRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation

protocol UserRepository {
    func fetchUser() async -> Result<User?, AppError>
    func fetchAllUsersExceptCurrent() async -> Result<[User?], AppError>
    func fetchUserById(userId: String) async -> Result<User?, AppError>
    func deleteUserData(userId: String) async -> Result<Void, AppError>
}
