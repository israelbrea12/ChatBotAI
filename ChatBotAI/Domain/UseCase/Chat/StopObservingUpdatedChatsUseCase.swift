//
//  StopObservingUpdatedChatsUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import Foundation

class StopObservingUpdatedChatsUseCase: UseCaseProtocol {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(with input: Void) async -> Result<Void, AppError> {
        await chatRepository.stopObservingUpdatedChats()
    }
}
