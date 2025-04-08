//
//  ObserveUpdatedChatsUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import Foundation

class ObserveUpdatedChatsUseCase {
    private let chatRepository: ChatRepository

    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    func execute(onChatUpdated: @escaping (Chat) -> Void) {
        chatRepository.observeUpdatedChats(onUpdatedChat: onChatUpdated)
    }
}
