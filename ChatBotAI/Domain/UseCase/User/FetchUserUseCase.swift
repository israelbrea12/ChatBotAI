//
//  fetchUserUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/3/25.
//

import Foundation

class FetchUserUseCase: UseCaseProtocol {
    
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(with params: Void) async -> Result<User?, AppError> {
        await repository.fetchUser()
    }
}
