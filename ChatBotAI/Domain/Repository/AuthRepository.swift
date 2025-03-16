//
//  AuthRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

protocol AuthRepository {
    func signIn(email: String, password: String) async -> Result<User, AppError>
    func signUp(email: String, password: String, fullName: String) async -> Result<User, AppError>
    func signOut() -> Result<Bool, AppError>
    func fetchUser() async -> Result<User?, AppError>
}
