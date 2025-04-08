//
//  fetchMessagesUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import Foundation

class FetchMessagesUseCase {
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }

    func execute(chatId: String) async -> Result<[Message], AppError> {
        await messageRepository.fetchMessages(chatId: chatId)
    }
}
