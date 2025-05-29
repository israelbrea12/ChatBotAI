//
//  MessageDataSource.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation
import FirebaseDatabase

protocol MessageDataSource {
    func sendMessage(chatId: String, message: Message) async throws
    func fetchMessages(chatId: String) async throws -> [MessageModel]
    func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void)
    func stopObservingMessages(for chatId: String)
}


class MessageDataSourceImpl: MessageDataSource {
    private let databaseRef = Database.database().reference()
    private var messageObservers: [String: DatabaseHandle] = [:]
        
    func sendMessage(chatId: String, message: Message) async throws {
        let messageId = databaseRef.child("chats").child(chatId).child("messages").childByAutoId().key ?? UUID().uuidString
          
        let sentAt = Date().timeIntervalSince1970
        
        let messageData: [String: Any] = [
            "id": messageId,
            "text": message.text,
            "senderId": message.senderId,
            "senderName": message.senderName,
            "sentAt": sentAt
        ]
            
        let messageRef = databaseRef
            .child("chats")
            .child(chatId)
            .child("messages")
            .child(messageId)
            
        try await setValueAsync(messageRef, value: messageData)
            
        // Actualizar lastMessage del chat
        let lastMessageData: [String: Any] = [
            "text": message.text,
            "senderId": message.senderId,
            "sentAt": sentAt
        ]
            
        let chatRef = databaseRef
            .child("chats")
            .child(chatId)
            .child("lastMessage")
            
        try await setValueAsync(chatRef, value: lastMessageData)
    }
    
    
    private func setValueAsync(_ ref: DatabaseReference, value: Any) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            ref.setValue(value) { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    
    func fetchMessages(chatId: String) async throws -> [MessageModel] {
        try await withCheckedThrowingContinuation { continuation in
            let messagesRef = databaseRef
                .child("chats")
                .child(chatId)
                .child("messages")

            messagesRef.observeSingleEvent(of: .value) { snapshot in
                var messages: [MessageModel] = []

                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let value = childSnapshot.value as? [String: Any],
                       let id = value["id"] as? String,
                       let text = value["text"] as? String,
                       let senderId = value["senderId"] as? String,
                       let senderName = value["senderName"] as? String,
                       let sentAt = value["sentAt"] as? TimeInterval {
                        
                        let message = MessageModel(
                            id: id,
                            text: text,
                            senderId: senderId,
                            senderName: senderName,
                            sentAt: sentAt
                        )
                        messages.append(message)
                    }
                }

                // Ordenar por fecha de envío
                messages.sort { $0.sentAt < $1.sentAt }

                continuation.resume(returning: messages)
            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void) {
        let messagesRef = databaseRef.child("chats").child(chatId).child("messages")
        let handle = messagesRef.observe(.childAdded) { snapshot in
            guard
                let messageData = snapshot.value as? [String: Any],
                let jsonData = try? JSONSerialization.data(withJSONObject: messageData),
                let message = try? JSONDecoder().decode(MessageModel.self, from: jsonData)
            else {
                return
            }
            onNewMessage(message)
        }
        
        messageObservers[chatId] = handle
    }

    func stopObservingMessages(for chatId: String) {
        if let handle = messageObservers[chatId] {
            // Corregir la ruta aquí:
            databaseRef.child("chats").child(chatId).child("messages").removeObserver(withHandle: handle)
            messageObservers.removeValue(forKey: chatId)
            print("Firebase observer stopped for chatId: \(chatId)")
        } else {
            print("No observer found to stop for chatId: \(chatId)")
        }
    }
}
