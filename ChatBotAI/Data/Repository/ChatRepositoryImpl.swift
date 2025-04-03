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
            let chatModel = try await chatDataSource.createChat(otherUserId: userId)
            return .success(chatModel.toDomain())
        } catch {
            return .failure(error.toAppError())
        }
    }
}
