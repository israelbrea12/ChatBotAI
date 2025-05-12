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
    func observeAllChatActivity(userId: String, onChatEvent: @escaping (ChatModel) -> Void)
    func stopObservingAllChatActivity(userId: String) async
}

class ChatDataSourceImpl: ChatDataSource {
    
    
    private let databaseRef = Database.database().reference()
    
    private var userChatsListenerHandle: DatabaseHandle?
        private var userChatsRefForActivity: DatabaseReference?
        private var individualChatListeners: [String: DatabaseHandle] = [:]
        private var individualChatRefsForActivity: [String: DatabaseReference] = [:]
        
    
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
                let chatModel = ChatModel.toData(chatData, chatId: chatId)
                chatModels.append(chatModel)
            }
        }
        print("Chat IDs encontrados: \(chatIds)")

        return chatModels
    }
    
    func observeAllChatActivity(userId: String, onChatEvent: @escaping (ChatModel) -> Void) {
            // Detener cualquier observador anterior para este usuario para evitar duplicados
            Task { await stopObservingAllChatActivity(userId: userId) }

            userChatsRefForActivity = databaseRef.child("user_chats").child(userId).child("chats")
            
            print("FirebaseDataSource: Iniciando observeAllChatActivity para usuario \(userId)")

            // 1. Observar cuando se añade un nuevo chatId a la lista de chats del usuario
            userChatsListenerHandle = userChatsRefForActivity?.observe(.childAdded, with: { [weak self] userChatSnapshot in
                guard let self = self else { return }
                let chatId = userChatSnapshot.key
                print("FirebaseDataSource: Nuevo chatId \(chatId) detectado para usuario \(userId)")

                // 2. Para cada chatId (nuevo o ya existente que se reprocesa), observar el nodo de chat real en /chats/<chatId>
                if self.individualChatListeners[chatId] == nil { // Solo si no lo estamos observando ya
                    let specificChatRef = self.databaseRef.child("chats").child(chatId)
                    self.individualChatRefsForActivity[chatId] = specificChatRef
                    
                    let handle = specificChatRef.observe(.value, with: { chatDataSnapshot in
                        if chatDataSnapshot.exists(), let chatData = chatDataSnapshot.value as? [String: Any] {
                            print("FirebaseDataSource: Evento de datos para chat \(chatId)")
                            let model = ChatModel.toData(chatData, chatId: chatDataSnapshot.key)
                            onChatEvent(model)
                        } else {
                             print("FirebaseDataSource: Chat \(chatId) eliminado o datos no válidos.")
                            // Podrías querer notificar la eliminación si manejas la eliminación de chats.
                            // Por ahora, simplemente no llamamos a onChatEvent.
                            // También sería bueno limpiar el listener si el chat es borrado.
                            if !chatDataSnapshot.exists() {
                                self.individualChatRefsForActivity[chatId]?.removeObserver(withHandle: self.individualChatListeners[chatId]!)
                                self.individualChatListeners.removeValue(forKey: chatId)
                                self.individualChatRefsForActivity.removeValue(forKey: chatId)
                                print("FirebaseDataSource: Observador para chat \(chatId) eliminado porque el chat ya no existe.")
                            }
                        }
                    })
                    self.individualChatListeners[chatId] = handle
                }
            })
            
            // (Opcional) Observar cuando un chatId es eliminado de la lista del usuario
            userChatsRefForActivity?.observe(.childRemoved, with: { [weak self] userChatSnapshot in
                guard let self = self else { return }
                let chatId = userChatSnapshot.key
                print("FirebaseDataSource: ChatId \(chatId) eliminado de la lista del usuario \(userId)")
                if let handle = self.individualChatListeners[chatId], let ref = self.individualChatRefsForActivity[chatId] {
                    ref.removeObserver(withHandle: handle)
                    self.individualChatListeners.removeValue(forKey: chatId)
                    self.individualChatRefsForActivity.removeValue(forKey: chatId)
                    // Aquí podrías querer enviar un evento especial al ViewModel para que elimine el chat de la UI.
                    // Por ahora, solo dejamos de observarlo. El ViewModel tendrá que manejar la ausencia.
                }
            })
        }

        func stopObservingAllChatActivity(userId: String) async {
            print("FirebaseDataSource: Deteniendo observeAllChatActivity para usuario \(userId)")
            if let handle = userChatsListenerHandle, let ref = userChatsRefForActivity {
                ref.removeAllObservers() // Detiene .childAdded, .childRemoved, etc. en userChatsRefForActivity
                userChatsListenerHandle = nil
                userChatsRefForActivity = nil
                print("FirebaseDataSource: Observadores en user_chats/\(userId)/chats detenidos.")
            }

            for (chatId, handle) in individualChatListeners {
                if let ref = individualChatRefsForActivity[chatId] {
                    ref.removeObserver(withHandle: handle)
                    print("FirebaseDataSource: Observador para chat \(chatId) detenido.")
                }
            }
            individualChatListeners.removeAll()
            individualChatRefsForActivity.removeAll()
            print("FirebaseDataSource: Todos los observadores individuales de chats detenidos.")
        }

}
