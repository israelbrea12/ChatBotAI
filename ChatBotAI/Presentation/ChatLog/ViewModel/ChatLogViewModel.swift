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
    @Published var userPresenceStatus: String = ""
    @Published var editingMessage: Message? = nil

    // MARK: - Private vars
    private var chatId: String?
    private var otherUser: User?
    
    // MARK: - Use Cases
    private let sendMessageUseCase: SendMessageUseCase
    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let observeMessagesUseCase: ObserveMessagesUseCase
    private let deleteMessageUseCase: DeleteMessageUseCase
    private let uploadImageUseCase: UploadImageUseCase
    private let observePresenceUseCase: ObservePresenceUseCase
    private let editMessageUseCase: EditMessageUseCase
    private let getLastMessageUseCase: GetLastMessageUseCase
    private let updateChatLastMessageUseCase: UpdateChatLastMessageUseCase

    // MARK: - Lifecycle functions
    init(
        sendMessageUseCase: SendMessageUseCase,
        fetchMessagesUseCase: FetchMessagesUseCase,
        observeMessagesUseCase: ObserveMessagesUseCase,
        deleteMessageUseCase: DeleteMessageUseCase,
        uploadImageUseCase: UploadImageUseCase,
        observePresenceUseCase: ObservePresenceUseCase,
        editMessageUseCase: EditMessageUseCase,
        getLastMessageUseCase: GetLastMessageUseCase,
        updateChatLastMessageUseCase: UpdateChatLastMessageUseCase
        
    ) {
        self.sendMessageUseCase = sendMessageUseCase
        self.fetchMessagesUseCase = fetchMessagesUseCase
        self.observeMessagesUseCase = observeMessagesUseCase
        self.deleteMessageUseCase = deleteMessageUseCase
        self.uploadImageUseCase = uploadImageUseCase
        self.observePresenceUseCase = observePresenceUseCase
        self.editMessageUseCase = editMessageUseCase
        self.getLastMessageUseCase = getLastMessageUseCase
        self.updateChatLastMessageUseCase = updateChatLastMessageUseCase
    }

    // MARK: - Functions
    func setupChat(currentUser: User, otherUser: User) {
        self.otherUser = otherUser
        chatId = generateChatId(for: currentUser.id, and: otherUser.id)
        
        Task {
            await loadMessages()
            
            if let chatId = chatId {
                // Los observadores de mensajes ahora solo actualizan la lista local de mensajes.
                // La lógica de `lastMessage` del chat principal se manejará explícitamente.
                observeMessagesUseCase.execute(chatId: chatId) { [weak self] newMessage in
                    guard let self = self else { return }
                    if let index = self.messages.firstIndex(where: { $0.id == newMessage.id }) {
                        self.messages[index] = newMessage
                    } else {
                        self.messages.append(newMessage)
                    }
                    // No es necesario actualizar lastMessage del chat aquí, ya se hace al enviar/editar
                } onUpdatedMessage: { [weak self] updatedMessage in
                    guard let self = self else { return }
                    if let index = self.messages.firstIndex(where: { $0.id == updatedMessage.id }) {
                        self.messages[index] = updatedMessage
                    }
                    // No es necesario actualizar lastMessage del chat aquí, ya se hace al editar
                } onDeletedMessage: { [weak self] deletedMessageId in
                    self?.messages.removeAll { $0.id == deletedMessageId }
                    // No es necesario actualizar lastMessage del chat aquí, ya se hace al eliminar
                }
            }
            
            observeUserPresence()
        }
    }
    
    private func observeUserPresence() {
        guard let otherUserId = otherUser?.id else { return }
        
        observePresenceUseCase.execute(for: otherUserId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let presence):
                    self?.updatePresenceStatus(presence: presence)
                case .failure(let error):
                    print("Error observing presence: \(error.localizedDescription)")
                    self?.userPresenceStatus = ""
                }
            }
        }
    }
    
    private func updatePresenceStatus(presence: Presence) {
        if presence.isOnline {
            self.userPresenceStatus = NSLocalizedString("online_status", comment: "User is online")
        } else {
            let date = Date(timeIntervalSince1970: presence.lastSeen)
            let formatter = DateFormatter()
            formatter.doesRelativeDateFormatting = true
            
            if Calendar.current.isDateInToday(date) {
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                let format = NSLocalizedString("last_seen_today_at", comment: "")
                self.userPresenceStatus = String(format: format, formatter.string(from: date))
            } else if Calendar.current.isDateInYesterday(date) {
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                let format = NSLocalizedString("last_seen_yesterday_at", comment: "")
                self.userPresenceStatus = String(format: format, formatter.string(from: date))
            } else {
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                let format = NSLocalizedString("last_seen_on_date", comment: "")
                self.userPresenceStatus = String(format: format, formatter.string(from: date))
            }
        }
    }
    
    func sendOrEditMessage(currentUser: User?) {
        if let editingMessage = editingMessage {
            // Modo edición
            editMessage(editingMessage, newText: chatText, currentUser: currentUser)
        } else {
            // Modo envío normal
            sendTextMessage(currentUser: currentUser)
        }
    }

    private func sendTextMessage(currentUser: User?) {
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
                chatText = ""
                await updateChatLastMessage(with: message)
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
                    imageURL: imageURL.absoluteString
                )
                print("🟢 Enviando mensaje final con ID: \(finalMessage.id)")
                
                let sendResult = await self.sendMessageUseCase.execute(
                    with: SendMessageParams(chatId: chatId, message: finalMessage)
                )
                
                if case .failure(let error) = sendResult {
                    print("Error enviando mensaje de imagen a RTDB: \(error.localizedDescription)")
                    updateMessageStatus(id: messageId, isUploading: false, hasFailed: true)
                } else {
                    // Actualiza el lastMessage del chat padre al enviar la imagen final
                    await updateChatLastMessage(with: finalMessage)
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
    
    func stopObserving() {
        if let chatId = chatId {
            observeMessagesUseCase.stop(chatId: chatId)
        }
        if let otherUserId = otherUser?.id {
            observePresenceUseCase.stop(for: otherUserId)
        }
        print("Dejando de observar todo")
    }
    
    func deleteMessage(messageId: String) async {
        guard let chatId = chatId else { return }
        let result = await deleteMessageUseCase.execute(chatId: chatId, messageId: messageId)
        
        switch result {
        case .success:
            messages.removeAll { $0.id == messageId }
            await updateLastMessageAfterDeletion()
        case .failure(let error):
            print("Error eliminando mensaje: \(error.localizedDescription)")
            state = .error("No se pudo eliminar el mensaje.")
        }
    }
    
    func startEditingMessage(_ message: Message) {
        if message.messageType == .text {
            self.editingMessage = message
            self.chatText = message.text
        }
    }
    
    func cancelEditingMessage() {
        self.editingMessage = nil
        self.chatText = ""
    }
    
    private func editMessage(_ message: Message, newText: String, currentUser: User?) {
        guard let user = currentUser,
              let chatId = chatId,
              !newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        Task {
            let params = EditMessageParams(chatId: chatId, messageId: message.id, newText: newText)
            let result = await editMessageUseCase.execute(with: params)
            
            switch result {
            case .success:
                print("Mensaje editado con éxito: \(message.id)")
                self.chatText = ""
                self.editingMessage = nil
                // IMPORTANTE: Después de editar, actualiza el lastMessage del chat si era el editado
                // Puedes buscar el mensaje actualizado en `messages` o recrearlo
                if var editedMessageInList = messages.first(where: { $0.id == message.id }) {
                    editedMessageInList.text = newText
                    editedMessageInList.isEdited = true
                    await updateChatLastMessage(with: editedMessageInList)
                }
            case .failure(let error):
                print("Error editando mensaje: \(error.localizedDescription)")
                state = .error("Error al editar el mensaje.")
            }
        }
    }
    
    // NUEVO: Función auxiliar para actualizar el lastMessage del chat
    private func updateChatLastMessage(with message: Message?) async {
        guard let currentChatId = chatId else { return }
        let params = UpdateChatLastMessageParams(chatId: currentChatId, message: message)
        let result = await updateChatLastMessageUseCase.execute(with: params)
        switch result {
        case .success:
            print("ChatLogViewModel: lastMessage actualizado para chat \(currentChatId)")
        case .failure(let error):
            print("ChatLogViewModel: Error al actualizar lastMessage para chat \(currentChatId): \(error.localizedDescription)")
        }
    }
    
    // NUEVO: Función auxiliar para actualizar el lastMessage después de una eliminación
    private func updateLastMessageAfterDeletion() async {
        guard let currentChatId = chatId else { return }
        let result = await getLastMessageUseCase.execute(with: GetLastMessageParams(chatId: currentChatId))
        switch result {
        case .success(let lastMessage):
            await updateChatLastMessage(with: lastMessage)
        case .failure(let error):
            print("ChatLogViewModel: Error al obtener el último mensaje después de eliminar: \(error.localizedDescription)")
            await updateChatLastMessage(with: nil) // Tratar como si no hubiera mensajes si hay error
        }
    }
    
    // MARK: - Private functions
    private func generateChatId(for user1: String, and user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
}
