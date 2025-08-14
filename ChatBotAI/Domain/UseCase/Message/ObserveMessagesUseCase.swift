//
//  ObserveMessagesUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/5/25.
//

import Foundation


class ObserveMessagesUseCase {
    
    private let messageRepository: MessageRepository
    
    init(messageRepository: MessageRepository) {
        self.messageRepository = messageRepository
    }
    
    func execute(chatId: String, onNewMessage: @escaping (Message) -> Void,
                 onUpdatedMessage: @escaping (Message) -> Void,
                 onDeletedMessage: @escaping (String) -> Void) {
        messageRepository.observeMessages(chatId: chatId, onNewMessage: onNewMessage, onUpdatedMessage: onUpdatedMessage, onDeletedMessage: onDeletedMessage)
    }
    
    func stop(chatId: String) {
        messageRepository.stopObservingMessages(chatId: chatId)
    }
}
