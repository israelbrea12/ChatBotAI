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
    func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void, onDeletedMessage: @escaping (String) -> Void)
    func stopObservingMessages(for chatId: String)
    func deleteMessage(chatId: String, messageId: String) async throws
}

class MessageDataSourceImpl: MessageDataSource {
    private let databaseRef = Database.database().reference()
    private var messageObservers: [String: DatabaseHandle] = [:]
        
    func sendMessage(chatId: String, message: Message) async throws {
            // El ID del mensaje ya viene en el objeto `message` desde el ViewModel.
            // Usaremos este `message.id` como la clave del nodo en Firebase para consistencia.
            let messageId = message.id
            
            let sentAtValue = message.sentAt ?? Date().timeIntervalSince1970 // Asegura que sentAt tenga un valor

            // Prepara los datos del mensaje incluyendo los nuevos campos
            var messageData: [String: Any] = [
                "id": messageId, // Guarda el mismo ID dentro del objeto
                "text": message.text,
                "senderId": message.senderId,
                "senderName": message.senderName,
                "sentAt": sentAtValue,
                "messageType": message.messageType.rawValue // Guarda el rawValue del enum
            ]

            if message.messageType == .image, let imageURL = message.imageURL {
                messageData["imageURL"] = imageURL
            }
                
            let messageRef = databaseRef
                .child("chats")
                .child(chatId)
                .child("messages")
                .child(messageId) // Usa el message.id como clave del nodo
                
            try await setValueAsync(messageRef, value: messageData)
                
            // Actualizar lastMessage del chat
            var lastMessageText = message.text
            if message.messageType == .image {
                lastMessageText = "[Imagen]" // O podrías usar message.text si es un pie de foto
                if !message.text.isEmpty { // Si hay un pie de foto
                     lastMessageText = message.text
                }
            }

            let lastMessageData: [String: Any] = [
                "text": lastMessageText,
                "senderId": message.senderId,
                "sentAt": sentAtValue,
                "messageType": message.messageType.rawValue // Opcional: también guardar el tipo del último mensaje
            ]
            if message.messageType == .image, let imageURL = message.imageURL {
                 // Opcional: podrías querer guardar la URL del thumbnail o algo así.
                 // Por simplicidad, no lo añado aquí a menos que sea necesario.
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
                    .queryOrdered(byChild: "sentAt") // Ordena por sentAt al traerlos

                messagesRef.observeSingleEvent(of: .value) { snapshot in
                    var messages: [MessageModel] = []

                    for child in snapshot.children {
                        if let childSnapshot = child as? DataSnapshot,
                           let value = childSnapshot.value as? [String: Any] {
                            // Mapeo manual para incluir los nuevos campos
                            guard let id = value["id"] as? String,
                                  let text = value["text"] as? String, // Puede ser vacío para imágenes
                                  let senderId = value["senderId"] as? String,
                                  let senderName = value["senderName"] as? String,
                                  let sentAt = value["sentAt"] as? TimeInterval,
                                  let messageTypeString = value["messageType"] as? String else {
                                print("Skipping message due to missing essential fields: \(value)")
                                continue
                            }
                            
                            let imageURL = value["imageURL"] as? String // imageURL es opcional

                            let message = MessageModel(
                                id: id,
                                text: text,
                                senderId: senderId,
                                senderName: senderName,
                                sentAt: sentAt,
                                messageType: messageTypeString, // Se guarda como String
                                imageURL: imageURL
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
        
        func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void, onDeletedMessage: @escaping (String) -> Void) {
            let baseRef = databaseRef.child("chats").child(chatId).child("messages")
            let messagesQuery = baseRef
                                .queryOrdered(byChild: "sentAt")

            let addedHandle = messagesQuery.observe(.childAdded) { snapshot in
                guard let messageData = snapshot.value as? [String: Any] else {
                    print("Could not cast snapshot value to [String: Any]")
                    return
                }
                
                // Mapeo manual similar a fetchMessages
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

                let message = MessageModel(
                    id: id,
                    text: text,
                    senderId: senderId,
                    senderName: senderName,
                    sentAt: sentAt,
                    messageType: messageTypeString,
                    imageURL: imageURL
                )
                print("📩 Observado mensaje con ID: \(message.id)")
                onNewMessage(message)
            }
            
            let removedHandle = messagesQuery.observe(.childRemoved) { snapshot in
                    guard let messageData = snapshot.value as? [String: Any],
                          let id = messageData["id"] as? String else {
                        print("Could not get removed message data")
                        return
                    }

                    onDeletedMessage(id) // 👈 Aquí se notifica al ViewModel
                }

                messageObservers[chatId] = addedHandle
                messageObservers[chatId + "_removed"] = removedHandle
        }

        func stopObservingMessages(for chatId: String) {
            if let addedHandle = messageObservers[chatId] {
                databaseRef.child("chats").child(chatId).child("messages").removeObserver(withHandle: addedHandle)
                messageObservers.removeValue(forKey: chatId)
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

            try await messageRef.removeValue() // Más explícito para borrar
            
            // Opcional: Si el mensaje eliminado era el lastMessage, podrías querer actualizar lastMessage
            // buscando el mensaje anterior. Esto puede ser complejo y depende de tus necesidades.
        }
}
