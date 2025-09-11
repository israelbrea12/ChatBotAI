//
//  DeleteMessageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 29/5/25.
//

import Foundation

class DeleteMessageUseCase: UseCaseProtocol {
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(with params: DeleteMessageParams) async -> Result<Void, AppError> {
        await messageRepository.deleteMessage(chatId: params.chatId, messageId: params.messageId)
    }
}

