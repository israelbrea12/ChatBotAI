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
    
    func observeNewChats(onNewChat: @escaping (Chat) -> Void) {
        chatDataSource.observeNewChats { chatModel in
            onNewChat(chatModel.toDomain())
        }
    }
    
    func stopObservingNewChats() async -> Result<Void, AppError> {
        do {
            await chatDataSource.stopObservingNewChats()
            return .success(())
        } 
    }
    func observeUpdatedChats(onUpdatedChat: @escaping (Chat) -> Void) {
        chatDataSource.observeUpdatedChats { chatModel in
            onUpdatedChat(chatModel.toDomain())
        }
    }
    
    func stopObservingUpdatedChats() async -> Result<Void, AppError> {
        do {
            await chatDataSource.stopObservingUpdatedChats()
            return .success(())
        }
    }
}
