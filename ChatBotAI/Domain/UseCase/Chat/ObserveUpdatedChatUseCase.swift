//
//  ObserveUpdatedChatUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 1/5/25.
//

import Foundation

class ObserveUpdatedChatUseCase {
    private let chatRepository: ChatRepository

    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    func execute(chatId: String, onChatUpdated: @escaping (Chat) -> Void) {
        chatRepository.observeUpdatedChat(chatId: chatId, onUpdatedChat: onChatUpdated)
    }
}
