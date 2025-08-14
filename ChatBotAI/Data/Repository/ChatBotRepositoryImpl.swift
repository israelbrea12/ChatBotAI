//
//  ChatBotRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import Foundation

class ChatBotRepositoryImpl: ChatBotRepository {
    private let chatBotDataSource: ChatBotDataSource
    
    init(chatBotDataSource: ChatBotDataSource) {
        self.chatBotDataSource = chatBotDataSource
    }
    
    func sendMessageToChatBot(prompt: String) async -> Result<String, Error> {
        return await chatBotDataSource.generateResponse(prompt: prompt)
    }
    
    func sendMessageToChatBotStream(prompt: String) -> AsyncThrowingStream<String, Error> {
        return chatBotDataSource.generateResponseStream(prompt: prompt)
    }
}
