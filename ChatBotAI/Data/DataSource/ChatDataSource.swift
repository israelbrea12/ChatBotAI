//
//  ChatDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation
@preconcurrency import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage
import UIKit
import GoogleSignIn
import GoogleSignInSwift
import FirebaseCore
import AuthenticationServices

protocol ChatDataSource {
    func createChat(otherUserId: String) async throws -> ChatModel
}


class ChatDataSourceImpl: ChatDataSource {
    
    private let databaseRef = Database.database().reference()
        
    func createChat(otherUserId: String) async throws -> ChatModel {
        guard let currentUserId = await SessionManager.shared.currentUser?.id else {
            throw NSError(
                domain: "ChatRepository",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        let chatId = generateChatId(for: currentUserId, and: otherUserId)
        let chatRef = databaseRef.child("chats").child(chatId)

        let createdAt = Date().timeIntervalSince1970
        
        let chatData: [String: Any] = [
            "id": chatId,
            "participants": [currentUserId, otherUserId],
            "createdAt": createdAt
        ]

        try await chatRef.setValue(chatData)

        return ChatModel(
            id: chatId,
            participants: [currentUserId, otherUserId],
            createdAt: createdAt,
            lastMessage: nil
        )
    }

        
    private func generateChatId(for user1: String, and user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
}
