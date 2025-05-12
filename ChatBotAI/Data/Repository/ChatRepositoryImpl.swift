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
            // El dataSource debe ser async si sus operaciones de stop lo son
            Task { // Si chatDataSource.stopObservingAllChatActivity es async
                 await chatDataSource.stopObservingAllChatActivity(userId: userId)
            }
        }
}
