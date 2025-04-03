//
//  DeleteAccountUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 30/3/25.
//

import Foundation

class DeleteAccountUseCase: UseCaseProtocol {
    
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(with params: Void) async -> Result<Void, AppError> {
        await repository.deleteAccount()
    }
}
