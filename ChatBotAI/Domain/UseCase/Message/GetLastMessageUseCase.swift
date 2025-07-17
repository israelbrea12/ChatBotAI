//
//  GetLastMessageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/7/25.
//

import Foundation

class GetLastMessageUseCase: UseCaseProtocol {
    
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(with params: GetLastMessageParams) async -> Result<Message?, AppError> {
        await messageRepository.getLastMessage(chatId: params.chatId)
    }
}
