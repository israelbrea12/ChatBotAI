//
//  ChatRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

protocol ChatRepository {
    func createChat(userId: String) async -> Result<Chat, AppError>
    func fetchUserChats() async -> Result<[Chat], AppError>
    func observeAllChatEvents(userId: String, onChatEvent: @escaping (Chat) -> Void)
    func stopObservingAllChatEvents(userId: String)
    func deleteUserChat(userId: String, chatId: String) async -> Result<Void, AppError>
    func deleteAllUserChatsIds(userId: String) async -> Result<Void, AppError>
}
