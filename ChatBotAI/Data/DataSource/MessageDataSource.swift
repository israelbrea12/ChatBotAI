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
}


class MessageDataSourceImpl: MessageDataSource {
    private let databaseRef = Database.database().reference()
        
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

}
