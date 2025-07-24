//
//  UpdateUserLearningLanguageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 24/7/25.
//

import Foundation

struct UpdateUserLearningLanguageUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(language: String) async -> Result<Void, AppError> {
        return await userRepository.updateUserLearningLanguage(language: language)
    }
}
