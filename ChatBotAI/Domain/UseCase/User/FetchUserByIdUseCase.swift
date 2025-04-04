//
//  FetchUserByIdUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 4/4/25.
//

import Foundation

class FetchUserByIdUseCase: UseCaseProtocol {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(with params: FetchUserByIdParams) async -> Result<User?, AppError> {
        await repository.fetchUserById(userId: params.userId)
    }
}
