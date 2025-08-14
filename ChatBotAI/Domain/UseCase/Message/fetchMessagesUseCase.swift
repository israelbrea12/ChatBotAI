//
//  fetchMessagesUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import Foundation

class FetchMessagesUseCase: UseCaseProtocol {
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(with params: FetchMessagesParams) async -> Result<[Message], AppError> {
        await messageRepository.fetchMessages(chatId: params.chatId)
    }
}
