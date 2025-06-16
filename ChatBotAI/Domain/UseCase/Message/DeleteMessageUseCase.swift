//
//  DeleteMessageParams.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 29/5/25.
//


//
//  DeleteMessageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 29/5/25.
//

import Foundation

class DeleteMessageUseCase {
    private let messageRepository: MessageRepository

    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }

    func execute(chatId: String, messageId: String) async -> Result<Void, AppError> {
        await messageRepository.deleteMessage(chatId: chatId, messageId: messageId)
    }
}

