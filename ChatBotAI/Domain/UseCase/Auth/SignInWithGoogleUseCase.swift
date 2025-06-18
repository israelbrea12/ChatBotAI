//
//  SignInWithGoogleUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 30/3/25.
//

import Foundation

struct SignInWithGoogleUseCase {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute() async -> Result<User, AppError> {
        await repository.signInWithGoogle()
    }
}
