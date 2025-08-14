//
//  UpdateUserLearningLanguageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 24/7/25.
//

import Foundation

struct UpdateUserLearningLanguageUseCase: UseCaseProtocol {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(with params: UpdateUserLearningLanguageParams) async -> Result<Void, AppError> {
        return await userRepository.updateUserLearningLanguage(language: params.language)
    }
}
