//
//  SignInWithAppleUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 2/4/25.
//

import Foundation

class SignInWithAppleUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() async -> Result<User, AppError> {
        await repository.signInWithApple()
    }
}
