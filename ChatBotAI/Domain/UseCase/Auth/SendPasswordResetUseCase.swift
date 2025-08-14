//
//  SendPasswordResetUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 4/7/25.
//

import Foundation

struct SendPasswordResetUseCase: UseCaseProtocol {
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository) {
        self.authRepository = authRepository
    }
    
    func execute(with params: SendPasswordResetParams) async -> Result<Void, AppError> {
        await authRepository.sendPasswordReset(email: params.email)
    }
}
