//
//  MessageRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation
import UIKit

class MessageRepositoryImpl: MessageRepository {
    
    private let messageDataSource: MessageDataSource
    
    init(messageDataSource: MessageDataSource) {
        self.messageDataSource = messageDataSource
    }
    
    func sendMessage(chatId: String, message: Message) async -> Result<Bool, AppError> {
        do{
            try  await messageDataSource
                .sendMessage(chatId: chatId, message: message)
            return .success(true)
        }catch{
            return .failure(error.toAppError())
        }
    }
    
    func fetchMessages(chatId: String) async -> Result<[Message], AppError> {
        do {
            let models = try await messageDataSource.fetchMessages(
                chatId: chatId
            )
            return .success(models.map { $0.toDomain() })
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func observeMessages(chatId: String,
                         onNewMessage: @escaping (Message) -> Void,
                         onDeletedMessage: @escaping (String) -> Void) {
        messageDataSource.observeMessages(
            for: chatId,
            onNewMessage: { messageModel in
                onNewMessage(messageModel.toDomain())
            },
            onDeletedMessage: { messageId in
                onDeletedMessage(messageId)
            }
        )
    }

    func stopObservingMessages(chatId: String) {
        messageDataSource.stopObservingMessages(for: chatId)
    }

    func deleteMessage(chatId: String, messageId: String) async -> Result<Void, AppError> {
        do {
            try await messageDataSource.deleteMessage(chatId: chatId, messageId: messageId)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
}
