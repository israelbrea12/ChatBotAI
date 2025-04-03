//
//  ChatRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

protocol ChatRepository {
    func createChat(userId: String) async -> Result<Chat, AppError>
}
