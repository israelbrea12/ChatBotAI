//
//  ChatDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation
import FirebaseDatabase

protocol ChatDataSource {
    func createChat(otherUserId: String) async throws -> ChatModel
    func fetchUserChats() async throws -> [ChatModel]
    func observeNewChats(onNewChat: @escaping (ChatModel) -> Void)
    func stopObservingNewChats()  async -> Void
}


class ChatDataSourceImpl: ChatDataSource {
    
    private let databaseRef = Database.database().reference()
    private var newChatsHandle: DatabaseHandle?
    private var userChatsRef: DatabaseReference?
        
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

        // Guardar referencias en user_chats para ambos usuarios
        let userChatsRefCurrent = databaseRef.child("user_chats").child(currentUserId).child("chats").child(
            chatId
        )
        let userChatsRefOther = databaseRef.child("user_chats").child(otherUserId).child("chats").child(
            chatId
        )

        try await userChatsRefCurrent.setValue(true)
        try await userChatsRefOther.setValue(true)
        
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
    
    func fetchUserChats() async throws -> [ChatModel] {
        guard let currentUserId = await SessionManager.shared.currentUser?.id else {
            throw NSError(
                domain: "ChatRepository",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "User not authenticated"]
            )
        }

        let userChatsSnapshot = try await databaseRef
            .child("user_chats")
            .child(currentUserId)
            .child("chats")
            .getData()

        guard let userChatsDict = userChatsSnapshot.value as? [String: Any] else {
            return []
        }

        let chatIds = Array(userChatsDict.keys)
        var chatModels: [ChatModel] = []

        for chatId in chatIds {
            let chatSnapshot = try await databaseRef.child("chats").child(chatId).getData()
            if let chatData = chatSnapshot.value as? [String: Any] {
                let participants = chatData["participants"] as? [String] ?? []
                let createdAt = chatData["createdAt"] as? Double ?? 0
                let lastMessage = chatData["lastMessage"] as? LastMessageModel

                let chatModel = ChatModel(
                    id: chatId,
                    participants: participants,
                    createdAt: createdAt,
                    lastMessage: lastMessage
                )
                chatModels.append(chatModel)
            }
        }
        print("Chat IDs encontrados: \(chatIds)")

        return chatModels
    }
    
    func observeNewChats(onNewChat: @escaping (ChatModel) -> Void) {
        Task { @MainActor in
            guard let currentUserId = SessionManager.shared.currentUser?.id else {
                return
            }

            userChatsRef = databaseRef.child("user_chats").child(currentUserId).child("chats")

            newChatsHandle = userChatsRef?.observe(.childAdded) { snapshot in
                let chatId = snapshot.key
                self.databaseRef.child("chats").child(chatId).observeSingleEvent(of: .value) { chatSnapshot in
                    if let chatData = chatSnapshot.value as? [String: Any] {
                        let participants = chatData["participants"] as? [String] ?? []
                        let createdAt = chatData["createdAt"] as? Double ?? 0
                        let lastMessage = chatData["lastMessage"] as? LastMessageModel

                        let chatModel = ChatModel(
                            id: chatId,
                            participants: participants,
                            createdAt: createdAt,
                            lastMessage: lastMessage
                        )
                        onNewChat(chatModel)
                    }
                }
            }
        }
    }

    func stopObservingNewChats() async {
        if let handle = newChatsHandle, let ref = userChatsRef {
            ref.removeObserver(withHandle: handle)
            newChatsHandle = nil
            userChatsRef = nil
        }
    }
}
