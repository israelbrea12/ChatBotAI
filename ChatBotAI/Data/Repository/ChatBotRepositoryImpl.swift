//
//  ChatBotRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//


// Data/Repositories/ChatBotRepositoryImpl.swift
import Foundation

class ChatBotRepositoryImpl: ChatBotRepository {
    private let chatBotDataSource: ChatBotDataSource

    init(chatBotDataSource: ChatBotDataSource) {
        self.chatBotDataSource = chatBotDataSource
    }

    func sendMessageToChatBot(prompt: String) async -> Result<String, Error> {
        // Aquí se podría mapear errores del DataSource a errores del Dominio si fueran diferentes
        return await chatBotDataSource.generateResponse(prompt: prompt)
    }
}
