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
    func getLastMessage(chatId: String) async throws -> MessageModel?
}

class MessageDataSourceImpl: MessageDataSource {
    private let databaseRef = Database.database().reference()
    private var messageObservers: [String: DatabaseHandle] = [:]
    private var messageUpdatedObservers: [String: DatabaseHandle] = [:]
    
    func sendMessage(chatId: String, message: Message) async throws {
        let messageData = message.toFirebaseData()
        
        let messageRef = databaseRef
            .child(Constants.Database.chats)
            .child(chatId)
            .child(Constants.Database.messages)
            .child(message.id)
        
        try await setValueAsync(messageRef, value: messageData)
        
        var lastMessageText: String
        if message.messageType == .image {
            lastMessageText = message.text.isEmpty ? Constants.DefaultValues.defaultImageText : message.text
        } else {
            lastMessageText = message.text
        }
        
        let lastMessageData: [String: Any] = [
            Constants.Database.Message.text: lastMessageText,
            Constants.Database.Message.senderId: message.senderId,
            Constants.Database.Message.sentAt: message.sentAt ?? Date().timeIntervalSince1970,
            Constants.Database.Message.messageType: message.messageType.rawValue
        ]
        
        let chatRef = databaseRef
            .child(Constants.Database.chats)
            .child(chatId)
            .child(Constants.Database.Chat.lastMessage)
        
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
                .child(Constants.Database.chats)
                .child(chatId)
                .child(Constants.Database.messages)
                .queryOrdered(byChild: Constants.Database.Message.sentAt)
            
            messagesRef.observeSingleEvent(of: .value) { snapshot in
                var messages: [MessageModel] = []
                
                for child in snapshot.children {
                    if let childSnapshot = child as? DataSnapshot,
                       let value = childSnapshot.value as? [String: Any] {
                        guard let id = value[Constants.Database.Message.id] as? String,
                              let text = value[Constants.Database.Message.text] as? String,
                              let senderId = value[Constants.Database.Message.senderId] as? String,
                              let senderName = value[Constants.Database.Message.senderName] as? String,
                              let sentAt = value[Constants.Database.Message.sentAt] as? TimeInterval,
                              let messageTypeString = value[Constants.Database.Message.messageType] as? String else {
                            continue
                        }
                        
                        let imageURL = value[Constants.Database.Message.imageURL] as? String
                        let isEdited = value[Constants.Database.Message.isEdited] as? Bool ?? false
                        let replyTo = value[Constants.Database.Message.replyTo] as? String
                        
                        let message = MessageModel(
                            id: id,
                            text: text,
                            senderId: senderId,
                            senderName: senderName,
                            sentAt: sentAt,
                            messageType: messageTypeString,
                            imageURL: imageURL,
                            isEdited: isEdited,
                            replyTo: replyTo
                        )
                        messages.append(message)
                    }
                }
                continuation.resume(returning: messages)
            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void, onUpdatedMessage: @escaping (MessageModel) -> Void, onDeletedMessage: @escaping (String) -> Void) {
        let baseRef = databaseRef.child(Constants.Database.chats).child(chatId).child(Constants.Database.messages)
        let messagesQuery = baseRef
            .queryOrdered(byChild: Constants.Database.Message.sentAt)
        
        let addedHandle = messagesQuery.observe(.childAdded) { snapshot in
            guard let messageData = snapshot.value as? [String: Any] else {
                return
            }
            
            guard let id = messageData[Constants.Database.Message.id] as? String,
                  let text = messageData[Constants.Database.Message.text] as? String,
                  let senderId = messageData[Constants.Database.Message.senderId] as? String,
                  let senderName = messageData[Constants.Database.Message.senderName] as? String,
                  let sentAt = messageData[Constants.Database.Message.sentAt] as? TimeInterval,
                  let messageTypeString = messageData[Constants.Database.Message.messageType] as? String else {
                return
            }
            
            let imageURL = messageData[Constants.Database.Message.imageURL] as? String
            let isEdited = messageData[Constants.Database.Message.isEdited] as? Bool ?? false
            let replyTo = messageData[Constants.Database.Message.replyTo] as? String
            
            let message = MessageModel(
                id: id,
                text: text,
                senderId: senderId,
                senderName: senderName,
                sentAt: sentAt,
                messageType: messageTypeString,
                imageURL: imageURL,
                isEdited: isEdited,
                replyTo: replyTo
            )
            print("📩 Observado mensaje con ID: \(message.id)")
            onNewMessage(message)
        }
        
        let changedHandle = messagesQuery.observe(.childChanged) { snapshot in
            guard let messageData = snapshot.value as? [String: Any] else {
                return
            }
            
            guard let id = messageData[Constants.Database.Message.id] as? String,
                  let text = messageData[Constants.Database.Message.text] as? String,
                  let senderId = messageData[Constants.Database.Message.senderId] as? String,
                  let senderName = messageData[Constants.Database.Message.senderName] as? String,
                  let sentAt = messageData[Constants.Database.Message.sentAt] as? TimeInterval,
                  let messageTypeString = messageData[Constants.Database.Message.messageType] as? String else {
                return
            }
            
            let imageURL = messageData[Constants.Database.Message.imageURL] as? String
            let isEdited = messageData[Constants.Database.Message.isEdited] as? Bool ?? false
            let replyTo = messageData[Constants.Database.Message.replyTo] as? String
            
            let updatedMessage = MessageModel(
                id: id,
                text: text,
                senderId: senderId,
                senderName: senderName,
                sentAt: sentAt,
                messageType: messageTypeString,
                imageURL: imageURL,
                isEdited: isEdited,
                replyTo: replyTo
            )
            print("Observado mensaje actualizado con ID: \(updatedMessage.id)")
            onUpdatedMessage(updatedMessage)
        }
        
        let removedHandle = messagesQuery.observe(.childRemoved) { snapshot in
            guard let messageData = snapshot.value as? [String: Any],
                  let id = messageData[Constants.Database.Message.id] as? String else {
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
            databaseRef.child(Constants.Database.chats).child(chatId).child(Constants.Database.messages).removeObserver(withHandle: addedHandle)
            messageObservers.removeValue(forKey: chatId)
        }
        if let changedHandle = messageUpdatedObservers[chatId] {
            databaseRef.child(Constants.Database.chats).child(chatId).child(Constants.Database.messages).removeObserver(withHandle: changedHandle)
            messageUpdatedObservers.removeValue(forKey: chatId)
        }
        if let removedHandle = messageObservers[chatId + "_removed"] {
            databaseRef.child(Constants.Database.chats).child(chatId).child(Constants.Database.messages).removeObserver(withHandle: removedHandle)
            messageObservers.removeValue(forKey: chatId + "_removed")
        } else {
            print("No se encontró ningún observador que detuviera el chatId: \(chatId)")
        }
    }
    
    func deleteMessage(chatId: String, messageId: String) async throws {
        let messageRef = databaseRef
            .child(Constants.Database.chats)
            .child(chatId)
            .child(Constants.Database.messages)
            .child(messageId)
        
        try await messageRef.removeValue()
    }
    
    func editMessage(chatId: String, messageId: String, newText: String) async throws {
        let messageRef = databaseRef
            .child(Constants.Database.chats)
            .child(chatId)
            .child(Constants.Database.messages)
            .child(messageId)
        
        let updates: [String: Any] = [
            Constants.Database.Message.text: newText,
            Constants.Database.Message.isEdited: true,
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
    
    func getLastMessage(chatId: String) async throws -> MessageModel? {
        return try await withCheckedThrowingContinuation { continuation in
            let messagesRef = databaseRef
                .child(Constants.Database.chats)
                .child(chatId)
                .child(Constants.Database.messages)
                .queryOrdered(byChild: Constants.Database.Message.sentAt)
                .queryLimited(toLast: 1)
            
            messagesRef.observeSingleEvent(of: .value) { snapshot in
                guard let lastChild = snapshot.children.allObjects.last as? DataSnapshot,
                      let value = lastChild.value as? [String: Any] else {
                    continuation.resume(returning: nil)
                    return
                }
                
                if let messageModel = self.mapMessageModel(from: value, key: lastChild.key) {
                    continuation.resume(returning: messageModel)
                } else {
                    continuation.resume(throwing: NSError(domain: Constants.Errors.Domain.messageDataSource, code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to map last message"]))
                }
            } withCancel: { error in
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func mapMessageModel(from value: [String: Any], key: String) -> MessageModel? {
        guard let id = value[Constants.Database.Message.id] as? String,
              let text = value[Constants.Database.Message.text] as? String,
              let senderId = value[Constants.Database.Message.senderId] as? String,
              let senderName = value[Constants.Database.Message.senderName] as? String,
              let sentAt = value[Constants.Database.Message.sentAt] as? TimeInterval,
              let messageTypeString = value[Constants.Database.Message.messageType] as? String else {
            return nil
        }
        
        let imageURL = value[Constants.Database.Message.imageURL] as? String
        let isEdited = value[Constants.Database.Message.isEdited] as? Bool ?? false
        let replyTo = value[Constants.Database.Message.replyTo] as? String
        
        return MessageModel(
            id: id,
            text: text,
            senderId: senderId,
            senderName: senderName,
            sentAt: sentAt,
            messageType: messageTypeString,
            imageURL: imageURL,
            isEdited: isEdited,
            replyTo: replyTo
        )
    }
}
