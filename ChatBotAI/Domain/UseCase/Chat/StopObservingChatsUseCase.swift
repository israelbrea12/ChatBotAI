//
//  StopObservingChatsUseCase.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

class StopObservingChatsUseCase: UseCaseProtocol {
    
    private let chatRepository: ChatRepository
    
    init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    func execute(with input: Void) async -> Result<Void, AppError> {
        await chatRepository.stopObservingNewChats()
    }
}
