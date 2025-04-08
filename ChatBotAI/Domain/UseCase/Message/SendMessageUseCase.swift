//
//  SendMessageUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

class SendMessageUseCase: UseCaseProtocol {
    
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(with params: SendMessageParams) async -> Result<Bool, AppError> {
        await messageRepository.sendMessage(chatId: params.chatId, message: params.message)
    }
}
