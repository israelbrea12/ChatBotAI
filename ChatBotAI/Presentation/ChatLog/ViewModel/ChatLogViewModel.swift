//
//  ChatLogViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import Foundation

@MainActor
class ChatLogViewModel: ObservableObject {
    
    // MARK: - Publisheds
    @Published var state: ViewState = .success
    @Published var chatText = ""
    @Published var messages: [Message] = []

    // MARK: - Private vars
    private var chatId: String?
    
    // MARK: - Use Cases
    private let sendMessageUseCase: SendMessageUseCase
    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let observeMessagesUseCase: ObserveMessagesUseCase
    private let deleteMessageUseCase: DeleteMessageUseCase
    private let uploadImageUseCase: UploadImageUseCase

    // MARK: - Lifecycle functions
    init(
        sendMessageUseCase: SendMessageUseCase,
        fetchMessagesUseCase: FetchMessagesUseCase,
        observeMessagesUseCase: ObserveMessagesUseCase,
        deleteMessageUseCase: DeleteMessageUseCase,
        uploadImageUseCase: UploadImageUseCase
    ) {
        self.sendMessageUseCase = sendMessageUseCase
        self.fetchMessagesUseCase = fetchMessagesUseCase
        self.observeMessagesUseCase = observeMessagesUseCase
        self.deleteMessageUseCase = deleteMessageUseCase
        self.uploadImageUseCase = uploadImageUseCase
    }

    // MARK: - Functions
    func setupChat(currentUser: User, otherUser: User) {
        chatId = generateChatId(for: currentUser.id, and: otherUser.id)
        
        Task {
            await loadMessages()
            
            if let chatId = chatId {
                observeMessagesUseCase.execute(chatId: chatId) { [weak self] newMessage in
                    guard let self = self else { return }
                    
                    if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                        self.messages[index] = newMessage
                    } else {
                        self.messages.append(newMessage)
                    }
                } onDeletedMessage: { [weak self] deletedMessageId in
                    self?.messages.removeAll { $0.id == deletedMessageId }
                }
            }
        }
    }

    func sendTextMessage(currentUser: User?) {
        guard let user = currentUser,
              let chatId = chatId else {
            return
        }
        
        let trimmedText = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return
        }
        
        let message = Message(
            id: UUID().uuidString,
            text: trimmedText,
            senderId: user.id,
            senderName: user.fullName ?? "",
            sentAt: Date().timeIntervalSince1970,
            messageType: .text
        )
        
        Task {
            let result = await sendMessageUseCase.execute(
                with: SendMessageParams(chatId: chatId, message: message)
            )
            
            switch result {
            case .success:
                chatText = "" // Limpia el campo de texto
            case .failure(let error):
                print("Error enviando mensaje de texto: \(error.localizedDescription)")
                state = .error("Error al enviar el mensaje")
            }
        }
    }
    
    func sendImageMessage(imageData: Data, currentUser: User?, caption: String = "") {
        guard let user = currentUser, let chatId = chatId else {
            print("Error: Usuario o chatId no disponible.")
            self.state = .error("No se pudo enviar la imagen.")
            return
        }
        
        let messageId = UUID().uuidString
        print("🔵 Enviando mensaje temporal con ID: \(messageId)")
        
        let tempMessage = Message(
            id: messageId,
            text: caption,
            senderId: user.id,
            senderName: user.fullName ?? "",
            sentAt: Date().timeIntervalSince1970,
            messageType: .image,
            imageURL: nil,
            localImageData: imageData,
            isUploading: true,
            uploadFailed: false
        )
        
        messages.append(tempMessage)
        
        Task {
            let uploadParams = UploadImageParams(imageData: imageData, chatId: chatId, messageId: messageId)
            let uploadResult = await self.uploadImageUseCase.execute(with: uploadParams)
            
            switch uploadResult {
            case .success(let imageURL):
                let finalMessage = Message(
                    id: messageId,
                    text: caption,
                    senderId: user.id,
                    senderName: user.fullName ?? "",
                    sentAt: tempMessage.sentAt,
                    messageType: .image,
                    imageURL: imageURL.absoluteString,
                )
                print("🟢 Enviando mensaje final con ID: \(finalMessage.id)")
                
                let sendResult = await self.sendMessageUseCase.execute(
                    with: SendMessageParams(chatId: chatId, message: finalMessage)
                )
                
                if case .failure(let error) = sendResult {
                    print("Error enviando mensaje de imagen a RTDB: \(error.localizedDescription)")
                    updateMessageStatus(id: messageId, isUploading: false, hasFailed: true)
                }
                
            case .failure(let error):
                // 5. Si la subida de la imagen falla, actualizamos el estado del mensaje en la UI
                print("Error al subir la imagen a Firebase Storage: \(error.localizedDescription)")
                updateMessageStatus(id: messageId, isUploading: false, hasFailed: true)
            }
        }
    }
    
    private func updateMessageStatus(id: String, isUploading: Bool, hasFailed: Bool) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].isUploading = isUploading
            messages[index].uploadFailed = hasFailed
        }
    }
    
    func loadMessages() async {
        guard let chatId = chatId else { return }

        let result = await fetchMessagesUseCase.execute(chatId: chatId)
        switch result {
        case .success(let fetchedMessages):
            self.messages = fetchedMessages
            self.state = .success
        case .failure(let error):
            print("Error fetching messages: \(error.localizedDescription)")
            self.state = .error("No se pudieron cargar los mensajes.")
        }
    }
    
    func stopObservingMessages() {
        if let chatId = chatId {
            observeMessagesUseCase.stop(chatId: chatId)
        }
        print("Dejando de observar mensajes")
    }
    
    func deleteMessage(messageId: String) async {
        guard let chatId = chatId else { return }
        let result = await deleteMessageUseCase.execute(chatId: chatId, messageId: messageId)
        
        switch result {
        case .success:
            messages.removeAll { $0.id == messageId }
        case .failure(let error):
            print("Error eliminando mensaje: \(error.localizedDescription)")
            state = .error("No se pudo eliminar el mensaje.")
        }
    }
    
    // MARK: - Private functions
    private func generateChatId(for user1: String, and user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
}
