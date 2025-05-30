//
//  ChatBotRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import Foundation

protocol ChatBotRepository {
    func sendMessageToChatBot(prompt: String) async -> Result<String, Error>
    func sendMessageToChatBotStream(prompt: String) -> AsyncThrowingStream<String, Error>
}
