//
//  ChatBotRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//


// Domain/Repositories/ChatBotRepository.swift
import Foundation

protocol ChatBotRepository {
    func sendMessageToChatBot(prompt: String) async -> Result<String, Error>
    // Podrías añadir más funciones como:
    // func fetchChatHistory() async -> Result<[ChatbotMessage], Error>
}
