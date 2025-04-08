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
    func observeNewChats(onNewChat: @escaping (Chat) -> Void)
    func stopObservingNewChats() async -> Result<Void, AppError>
    func observeUpdatedChats(onUpdatedChat: @escaping (Chat) -> Void)
}
