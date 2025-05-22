//
//  SendMessageUseCaseParams.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//


// Domain/UseCases/SendMessageUseCase.swift
import Foundation

// Protocolo (buena práctica, aunque solo tengas una implementación)
protocol SendMessageToChatBotUseCaseProtocol {
    func execute(with params: SendMessageToChatBotParams) async -> Result<String, Error>
}

class SendMessageToChatBotUseCase: SendMessageToChatBotUseCaseProtocol {
    private let chatBotRepository: ChatBotRepository

    init(chatBotRepository: ChatBotRepository) {
        self.chatBotRepository = chatBotRepository
    }

    func execute(with params: SendMessageToChatBotParams) async -> Result<String, Error> {
        // Aquí podrías añadir lógica adicional si fuera necesario antes o después de llamar al repositorio
        return await chatBotRepository.sendMessageToChatBot(prompt: params.prompt)
    }
}
