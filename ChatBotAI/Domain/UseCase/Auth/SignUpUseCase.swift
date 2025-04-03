//
//  CreateUserUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/3/25.
//

import Foundation
import UIKit

struct SignUpUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func execute(with params: SignUpParam, profileImage: UIImage?) async -> Result<User, AppError> {
        await repository.signUp(email: params.email, password: params.password, fullName: params.fullName, profileImage: profileImage)
    }
}

