//
//  SignInUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 14/3/25.
//

import Foundation

class SignInUseCase: UseCaseProtocol {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(with params: SignInParam) async -> Result<User, AppError> {
        await repository.signIn(email: params.email, password: params.password)
    }
}

