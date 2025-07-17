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
    func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void, onUpdatedMessage: @escaping (MessageModel) -> Void, onDeletedMessage: @escaping (String) -> Void)
    func stopObservingMessages(for chatId: String)
    func deleteMessage(chatId: String, messageId: String) async throws
    func editMessage(chatId: String, messageId: String, newText: String) async throws
}

class MessageDataSourceImpl: MessageDataSource {
    private let databaseRef = Database.database().reference()
    private var messageObservers: [String: DatabaseHandle] = [:]
    private var messageUpdatedObservers: [String: DatabaseHandle] = [:]
        
    func sendMessage(chatId: String, message: Message) async throws {
        let messageId = message.id
        
        let sentAtValue = message.sentAt ?? Date().timeIntervalSince1970
        
        var messageData: [String: Any] = [
            "id": messageId,
            "text": message.text,
            "senderId": message.senderId,
            "senderName": message.senderName,
            "sentAt": sentAtValue,
            "messageType": message.messageType.rawValue
        ]
        
        if message.messageType == .image, let imageURL = message.imageURL {
            messageData["imageURL"] = imageURL
        }
        
        if message.isEdited { // <-- NUEVO
            messageData["isEdited"] = true
        }
        
        let messageRef = databaseRef
            .child("chats")
            .child(chatId)
            .child("messages")
            .child(messageId)
        
        try await setValueAsync(messageRef, value: messageData)
        
        var lastMessageText = message.text
        if message.messageType == .image {
            lastMessageText = "[Imagen]"
            if !message.text.isEmpty {
                lastMessageText = message.text
            }
        }
        
        let lastMessageData: [String: Any] = [
            "text": lastMessageText,
            "senderId": message.senderId,
            "sentAt": sentAtValue,
            "messageType": message.messageType.rawValue
        ]
        if message.messageType == .image, let imageURL = message.imageURL {
        }
        
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
                .queryOrdered(byChild: "sentAt")
            
            messagesRef.observeSingleEvent(of: .value) { snapshot in
                var messages: [MessageModel] = []
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let value = childSnapshot.value as? [String: Any] {
                        guard let id = value["id"] as? String,
                              let text = value["text"] as? String,
                              let senderId = value["senderId"] as? String,
                              let senderName = value["senderName"] as? String,
                              let sentAt = value["sentAt"] as? TimeInterval,
                              let messageTypeString = value["messageType"] as? String else {
                            print("Skipping message due to missing essential fields: \(value)")
                            continue
                        }
                        
                        let imageURL = value["imageURL"] as? String
                        let isEdited = value["isEdited"] as? Bool ?? false
                        
                        let message = MessageModel(
                            id: id,
                            text: text,
                            senderId: senderId,
                            senderName: senderName,
                            sentAt: sentAt,
                            messageType: messageTypeString,
                            imageURL: imageURL,
                            isEdited: isEdited
                        )
                        messages.append(message)
                    }
                }
                // No necesitas ordenar aquí si usaste queryOrdered(byChild: "sentAt")
                // messages.sort { $0.sentAt < $1.sentAt } // Ya no es necesario si la query ordena
                continuation.resume(returning: messages)
            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
        
    func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void, onUpdatedMessage: @escaping (MessageModel) -> Void, onDeletedMessage: @escaping (String) -> Void) {
        let baseRef = databaseRef.child("chats").child(chatId).child("messages")
        let messagesQuery = baseRef
            .queryOrdered(byChild: "sentAt")
        
        let addedHandle = messagesQuery.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any] else {
                print("Could not cast snapshot value to [String: Any]")
                return
            }
            
            guard let id = messageData["id"] as? String,
                  let text = messageData["text"] as? String,
                  let senderId = messageData["senderId"] as? String,
                  let senderName = messageData["senderName"] as? String,
                  let sentAt = messageData["sentAt"] as? TimeInterval,
                  let messageTypeString = messageData["messageType"] as? String else {
                print("Skipping observed message due to missing essential fields: \(messageData)")
                return
            }
            
            let imageURL = messageData["imageURL"] as? String
            let isEdited = messageData["isEdited"] as? Bool ?? false
            
            let message = MessageModel(
                id: id,
                text: text,
                senderId: senderId,
                senderName: senderName,
                sentAt: sentAt,
                messageType: messageTypeString,
                imageURL: imageURL,
                isEdited: isEdited
            )
            print("📩 Observado mensaje con ID: \(message.id)")
            onNewMessage(message)
        }
        
        let changedHandle = messagesQuery.observe(.childChanged) { snapshot in
            guard let messageData = snapshot.value as? [String: Any] else {
                print("Could not cast updated snapshot value to [String: Any]")
                return
            }
            
            // Mapeo manual similar al anterior
            guard let id = messageData["id"] as? String,
                  let text = messageData["text"] as? String,
                  let senderId = messageData["senderId"] as? String,
                  let senderName = messageData["senderName"] as? String,
                  let sentAt = messageData["sentAt"] as? TimeInterval,
                  let messageTypeString = messageData["messageType"] as? String else {
                print("Skipping updated message due to missing essential fields: \(messageData)")
                return
            }
            
            let imageURL = messageData["imageURL"] as? String
            let isEdited = messageData["isEdited"] as? Bool ?? false // <-- NUEVO
            
            let updatedMessage = MessageModel(
                id: id,
                text: text,
                senderId: senderId,
                senderName: senderName,
                sentAt: sentAt,
                messageType: messageTypeString,
                imageURL: imageURL,
                isEdited: isEdited // <-- NUEVO
            )
            print("🔄 Observado mensaje actualizado con ID: \(updatedMessage.id)")
            onUpdatedMessage(updatedMessage) // Llama al nuevo callback
        }
        
        let removedHandle = messagesQuery.observe(.childRemoved) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let id = messageData["id"] as? String else {
                print("Could not get removed message data")
                return
            }
            
            onDeletedMessage(id)
        }
        
        messageObservers[chatId] = addedHandle
        messageUpdatedObservers[chatId] = changedHandle
        messageObservers[chatId + "_removed"] = removedHandle
    }

    func stopObservingMessages(for chatId: String) {
        if let addedHandle = messageObservers[chatId] {
            databaseRef.child("chats").child(chatId).child("messages").removeObserver(withHandle: addedHandle)
            messageObservers.removeValue(forKey: chatId)
        }
        if let changedHandle = messageUpdatedObservers[chatId] {
            databaseRef.child("chats").child(chatId).child("messages").removeObserver(withHandle: changedHandle)
            messageUpdatedObservers.removeValue(forKey: chatId)
        }
        if let removedHandle = messageObservers[chatId + "_removed"] {
            databaseRef.child("chats").child(chatId).child("messages").removeObserver(withHandle: removedHandle)
            messageObservers.removeValue(forKey: chatId + "_removed")
        } else {
            print("No observer found to stop for chatId: \(chatId)")
        }
    }
        
    func deleteMessage(chatId: String, messageId: String) async throws {
        let messageRef = databaseRef
            .child("chats")
            .child(chatId)
            .child("messages")
            .child(messageId)
        
        try await messageRef.removeValue()
    }
    
    func editMessage(chatId: String, messageId: String, newText: String) async throws {
        let messageRef = databaseRef
            .child("chats")
            .child(chatId)
            .child("messages")
            .child(messageId)
        
        let updates: [String: Any] = [
            "text": newText,
            "isEdited": true,
        ]
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            messageRef.updateChildValues(updates) { error, _ in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
