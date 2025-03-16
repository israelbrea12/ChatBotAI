//
//  SignOutUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/3/25.
//

import Foundation

class SignOutUseCase: UseCaseProtocol {
    private let repository: AuthRepository

    init(repository: AuthRepository) {
        self.repository = repository
    }

    func execute(with params: Void) -> Result<Bool, AppError> {
        return repository.signOut()
    }
}
