//
//  FetchAllUsersExceptCurrentUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 21/3/25.
//

import Foundation

class FetchUsersByLanguageUseCase: UseCaseProtocol {
    private let repository: UserRepository
    
    init(repository: UserRepository) {
        self.repository = repository
    }
    
    func execute(with params: FetchUsersByLanguageParams) async -> Result<[User?], AppError> {
        return await repository.fetchUsersByLanguage(language: params.language)
    }
}
