//
//  createChatUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

class CreateChatUseCase: UseCaseProtocol {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(with params: CreateChatParams) async -> Result<Chat, AppError> {
        await chatRepository.createChat(userId: params.userId)
    }
}
