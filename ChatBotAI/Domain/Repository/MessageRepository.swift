//
//  MessageRepository.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

protocol MessageRepository {
    func sendMessage(chatId: String, message: Message) async -> Result<Bool, AppError>
    func fetchMessages(chatId: String) async -> Result<[Message], AppError>
    func observeMessages(chatId: String,
                         onNewMessage: @escaping (Message) -> Void,
                         onUpdatedMessage: @escaping (Message) -> Void,
                         onDeletedMessage: @escaping (String) -> Void)
    func stopObservingMessages(chatId: String)
    func deleteMessage(chatId: String, messageId: String) async -> Result<Void, AppError>
    func editMessage(chatId: String, messageId: String, newText: String) async -> Result<Bool, AppError>
    func getLastMessage(chatId: String) async -> Result<Message?, AppError>
}

