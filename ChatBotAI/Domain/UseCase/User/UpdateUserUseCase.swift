//
//  UpdateUserUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 19/7/25.
//

import Foundation

struct UpdateUserUseCase {
    private let userRepository: UserRepository
    
    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }
    
    func execute(with params: UpdateUserParams) async -> Result<User, AppError> {
        return await userRepository.updateUserData(fullName: params.fullName, profileImage: params.profileImage)
    }
}
