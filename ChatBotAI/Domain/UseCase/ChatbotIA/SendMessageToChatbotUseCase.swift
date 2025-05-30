//
//  SendMessageUseCaseParams.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import Foundation

protocol SendMessageToChatBotUseCaseProtocol {
    func execute(with params: SendMessageToChatBotParams) async -> Result<String, Error>
    func executeStream(with params: SendMessageToChatBotParams) -> AsyncThrowingStream<String, Error>
}

class SendMessageToChatBotUseCase: SendMessageToChatBotUseCaseProtocol {
    private let chatBotRepository: ChatBotRepository

    init(chatBotRepository: ChatBotRepository) {
        self.chatBotRepository = chatBotRepository
    }

    func execute(with params: SendMessageToChatBotParams) async -> Result<String, Error> {
        return await chatBotRepository.sendMessageToChatBot(prompt: params.prompt)
    }
    
    func executeStream(with params: SendMessageToChatBotParams) -> AsyncThrowingStream<String, Error> {
        return chatBotRepository.sendMessageToChatBotStream(prompt: params.prompt)
    }
}
