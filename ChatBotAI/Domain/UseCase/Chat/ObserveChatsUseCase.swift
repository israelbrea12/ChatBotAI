//
//  ObserveChatsUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/5/25.
//


class ObserveUserChatsUseCase {
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(userId: String, onChatEvent: @escaping (Chat) -> Void) {
        chatRepository.observeAllChatEvents(userId: userId, onChatEvent: onChatEvent)
    }
    
    func stop(userId: String) {
        chatRepository.stopObservingAllChatEvents(userId: userId)
    }
}
