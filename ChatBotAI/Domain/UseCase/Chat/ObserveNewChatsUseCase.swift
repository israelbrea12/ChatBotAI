//
//  ObserveUserChatIdsUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

class ObserveNewChatsUseCase {
    private let chatRepository: ChatRepository

    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }

    func execute(onNewChat: @escaping (Chat) -> Void) {
        chatRepository.observeNewChats(onNewChat: onNewChat)
    }
}


