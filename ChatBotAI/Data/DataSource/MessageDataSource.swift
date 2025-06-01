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
        
        func observeMessages(for chatId: String, onNewMessage: @escaping (MessageModel) -> Void) {
            let messagesRef = databaseRef.child("chats").child(chatId).child("messages")
                               .queryOrdered(byChild: "sentAt") // Observar ordenado
                               .queryStarting(atValue: Date().timeIntervalSince1970) // Para no traer todos los antiguos con .childAdded

            // Nota: .childAdded con queryStarting puede ser complejo si quieres cargar historial y luego observar.
            // Una estrategia común es cargar el historial con observeSingleEvent y luego observar nuevos con .childAdded y queryStarting.
            // Para simplificar, si ya cargas todos los mensajes en `fetchMessages`, este observer puede que
            // necesite una lógica para no duplicar los mensajes iniciales.
            // O, si `fetchMessages` no se llama antes de `observeMessages`, este traerá todos uno por uno.

            let handle = messagesRef.observe(.childAdded) { snapshot in
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
                onNewMessage(message)
            }
            
            messageObservers[chatId] = handle
        }

        func stopObservingMessages(for chatId: String) {
            if let handle = messageObservers[chatId] {
                databaseRef.child("chats").child(chatId).child("messages").removeObserver(withHandle: handle)
                messageObservers.removeValue(forKey: chatId)
                print("Firebase observer stopped for chatId: \(chatId)")
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
