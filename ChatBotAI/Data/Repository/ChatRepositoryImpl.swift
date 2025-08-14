//
//  ChatRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation
import UIKit

class ChatRepositoryImpl: ChatRepository {
    
    private let chatDataSource: ChatDataSource
    
    init(chatDataSource: ChatDataSource) {
        self.chatDataSource = chatDataSource
    }
    
    func createChat(userId: String) async -> Result<Chat, AppError> {
        do {
            let chatModel = try await chatDataSource.createChat(
                otherUserId: userId
            )
            return .success(chatModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func fetchUserChats() async -> Result<[Chat], AppError> {
        do {
            let chatModels = try await chatDataSource.fetchUserChats()
            return .success(chatModels.map { $0.toDomain() })
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func observeAllChatEvents(userId: String, onChatEvent: @escaping (Chat) -> Void) {
        chatDataSource.observeAllChatActivity(userId: userId) { chatModel in
            onChatEvent(chatModel.toDomain())
        }
    }
    
    func stopObservingAllChatEvents(userId: String) {
        Task {
            await chatDataSource.stopObservingAllChatActivity(userId: userId)
        }
    }
    
    func deleteUserChat(userId: String, chatId: String) async -> Result<Void, AppError> {
        do {
            try await chatDataSource.deleteUserChat(userId: userId, chatId: chatId)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func deleteAllUserChatsIds(userId: String) async -> Result<Void, AppError> {
        do {
            try await chatDataSource.deleteAllUserChatsIds(userId: userId)
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
    
    func updateLastMessageForChat(chatId: String, message: Message?) async -> Result<Void, AppError> {
        do {
            if let message = message {
                let lastMessageData: [String: Any] = [
                    Constants.Database.Message.text: message.text,
                    Constants.Database.Message.senderId: message.senderId,
                    Constants.Database.Message.sentAt: message.sentAt ?? Date().timeIntervalSince1970,
                    Constants.Database.Message.messageType: message.messageType.rawValue,
                    Constants.Database.Message.isEdited: message.isEdited
                ]
                try await chatDataSource.updateChatLastMessage(chatId: chatId, lastMessageData: lastMessageData)
            } else {
                try await chatDataSource.updateChatLastMessage(chatId: chatId, lastMessageData: nil)
            }
            return .success(())
        } catch {
            return .failure(error.toAppError())
        }
    }
}
