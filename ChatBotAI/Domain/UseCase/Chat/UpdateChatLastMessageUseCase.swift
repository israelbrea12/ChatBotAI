//
//  UpdateChatLastMessageParams.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/7/25.
//


//
//  UpdateChatLastMessageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/7/25.
//

import Foundation

class UpdateChatLastMessageUseCase: UseCaseProtocol {
    private let chatRepository: ChatRepository // Usa ChatRepository, no MessageRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(with params: UpdateChatLastMessageParams) async -> Result<Void, AppError> {
        await chatRepository.updateLastMessageForChat(chatId: params.chatId, message: params.message)
    }
}
