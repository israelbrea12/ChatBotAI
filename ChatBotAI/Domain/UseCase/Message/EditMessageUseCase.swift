//
//  EditMessageParams.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/7/25.
//

import Foundation

class EditMessageUseCase: UseCaseProtocol {
    
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(with params: EditMessageParams) async -> Result<Bool, AppError> {
        await messageRepository.editMessage(chatId: params.chatId, messageId: params.messageId, newText: params.newText)
    }
}
