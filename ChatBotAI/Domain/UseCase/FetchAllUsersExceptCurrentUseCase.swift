//
//  FetchAllUsersExceptCurrentUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 21/3/25.
//

import Foundation

class FetchAllUsersExceptCurrentUseCase: UseCaseProtocol {
    
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(with params: Void) async -> Result<[User?], AppError> {
        await repository.fetchAllUsersExceptCurrent()
    }
}
