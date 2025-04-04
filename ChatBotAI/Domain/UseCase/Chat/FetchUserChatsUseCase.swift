//
//  FetchUserChatsUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 4/4/25.
//

import Foundation

class FetchUserChatsUseCase: UseCaseProtocol {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(with _: Void) async -> Result<[Chat], AppError> {
        await chatRepository.fetchUserChats()
    }
}
