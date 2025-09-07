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
    @Published var replyingToMessage: Message? = nil
    @Published var isTextFieldFocused: Bool = false
    
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
                observeMessagesUseCase.execute(chatId: chatId) { [weak self] newMessage in
                    guard let self = self else { return }
                    if !self.messages.contains(where: { $0.id == newMessage.id }) {
                        self.messages.append(newMessage)
                    }
                } onUpdatedMessage: { [weak self] updatedMessage in
                    guard let self = self, let index = self.messages.firstIndex(where: { $0.id == updatedMessage.id }) else { return }
                    self.messages[index] = updatedMessage
                    
                } onDeletedMessage: { [weak self] deletedMessageId in
                    self?.messages.removeAll { $0.id == deletedMessageId }
                }
            }
            observeUserPresence()
        }
    }
    
    func sendOrEditMessage(currentUser: User?) {
        if let replyingMessage = replyingToMessage {
            sendReplyMessage(to: replyingMessage, currentUser: currentUser)
        } else if let editingMessage = editingMessage {
            editMessage(editingMessage, newText: chatText, currentUser: currentUser)
        } else {
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
            senderName: user.fullName ?? LocalizedKeys.DefaultValues.defaultFullName,
            sentAt: Date().timeIntervalSince1970,
            messageType: .text,
            replyTo: replyingToMessage?.id
        )
        
        Task {
            let result = await sendMessageUseCase.execute(
                with: SendMessageParams(chatId: chatId, message: message)
            )
            
            switch result {
            case .success:
                chatText = ""
                cancelEditingMessage()
                cancelReplyingToMessage()
                await updateChatLastMessage(with: message)
            case .failure(let error):
                print("Error enviando mensaje de texto: \(error.localizedDescription)")
                state = .error(LocalizedKeys.AppError.sendMessage)
            }
        }
    }
    
    func sendImageMessage(imageData: Data, currentUser: User?, caption: String = "") {
        guard let user = currentUser, let chatId = chatId else {
            print("Error: Usuario o chatId no disponible.")
            self.state = .error(LocalizedKeys.AppError.sendImage)
            return
        }
        
        let messageId = UUID().uuidString
        print("🔵 Enviando mensaje temporal con ID: \(messageId)")
        
        let tempMessage = Message(
            id: messageId,
            text: caption,
            senderId: user.id,
            senderName: user.fullName ?? LocalizedKeys.DefaultValues.defaultFullName,
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
                    senderName: user.fullName ?? LocalizedKeys.DefaultValues.defaultFullName,
                    sentAt: tempMessage.sentAt,
                    messageType: .image,
                    imageURL: imageURL.absoluteString,
                    localImageData: nil, // Limpiamos los datos locales
                    isUploading: false,  // Ya no está subiendo
                    uploadFailed: false
                )
                print("🟢 Enviando mensaje final con ID: \(finalMessage.id)")
                
                let sendResult = await self.sendMessageUseCase.execute(
                    with: SendMessageParams(chatId: chatId, message: finalMessage)
                )
                
                if case .failure(let error) = sendResult {
                    print("Error enviando mensaje de imagen a RTDB: \(error.localizedDescription)")
                    updateMessageStatus(id: messageId, isUploading: false, hasFailed: true)
                } else {
                    // 👇 AÑADE ESTA LÍNEA AQUÍ
                    updateLocalMessage(withId: messageId, finalMessage: finalMessage)
                    await updateChatLastMessage(with: finalMessage)
                }
                
            case .failure(let error):
                print("Error al subir la imagen a Firebase Storage: \(error.localizedDescription)")
                updateMessageStatus(id: messageId, isUploading: false, hasFailed: true)
            }
        }
    }
    
    func startReplyingToMessage(_ message: Message) {
        if self.editingMessage != nil {
            cancelEditingMessage()
        }
        self.replyingToMessage = message
        self.isTextFieldFocused = true
        print("✅ Iniciando respuesta al mensaje ID: \(message.id)")
    }
    
    func cancelReplyingToMessage() {
        self.replyingToMessage = nil
    }
    
    func loadMessages() async {
        guard let chatId = chatId else { return }
        let result = await fetchMessagesUseCase.execute(with: FetchMessagesParams(chatId: chatId))
        switch result {
        case .success(let fetchedMessages):
            self.messages = fetchedMessages
            self.state = .success
        case .failure(let error):
            print("Error fetching messages: \(error.localizedDescription)")
            self.state = .error(LocalizedKeys.AppError.loadMessages)
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
        let result = await deleteMessageUseCase.execute(with: DeleteMessageParams(chatId: chatId, messageId: messageId))
        
        switch result {
        case .success:
            messages.removeAll { $0.id == messageId }
            await updateLastMessageAfterDeletion()
        case .failure(let error):
            print("Error eliminando mensaje: \(error.localizedDescription)")
            state = .error(LocalizedKeys.AppError.deleteMessage)
        }
    }
    
    func startEditingMessage(_ message: Message) {
        if message.messageType == .text {
            self.editingMessage = message
            self.chatText = message.text
            self.isTextFieldFocused = true
        }
    }
    
    func cancelEditingMessage() {
        self.editingMessage = nil
        self.chatText = ""
    }
    
    // MARK: - Private functions
    private func generateChatId(for user1: String, and user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
    
    private func sendReplyMessage(to originalMessage: Message, currentUser: User?) {
        guard let user = currentUser, let chatId = chatId else { return }
        let trimmedText = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }
        
        let replyMessage = Message(
            id: UUID().uuidString,
            text: trimmedText,
            senderId: user.id,
            senderName: user.fullName ?? LocalizedKeys.DefaultValues.defaultFullName,
            sentAt: Date().timeIntervalSince1970,
            messageType: .text,
            replyTo: originalMessage.id
        )
        
        Task {
            let result = await sendMessageUseCase.execute(with: .init(chatId: chatId, message: replyMessage))
            switch result {
            case .success:
                self.chatText = ""
                self.replyingToMessage = nil
                await updateChatLastMessage(with: replyMessage)
            case .failure(let error):
                print("Error enviando respuesta: \(error.localizedDescription)")
                self.state = .error(LocalizedKeys.AppError.sendMessage)
            }
        }
    }
    
    private func updateMessageStatus(id: String, isUploading: Bool, hasFailed: Bool) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index].isUploading = isUploading
            messages[index].uploadFailed = hasFailed
        }
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
                if var editedMessageInList = messages.first(where: { $0.id == message.id }) {
                    editedMessageInList.text = newText
                    editedMessageInList.isEdited = true
                    await updateChatLastMessage(with: editedMessageInList)
                }
            case .failure(let error):
                print("Error editando mensaje: \(error.localizedDescription)")
                state = .error(LocalizedKeys.AppError.editingMessage)
            }
        }
    }
    
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
    
    private func updateLastMessageAfterDeletion() async {
        guard let currentChatId = chatId else { return }
        let result = await getLastMessageUseCase.execute(with: GetLastMessageParams(chatId: currentChatId))
        switch result {
        case .success(let lastMessage):
            await updateChatLastMessage(with: lastMessage)
        case .failure(let error):
            print("ChatLogViewModel: Error al obtener el último mensaje después de eliminar: \(error.localizedDescription)")
            await updateChatLastMessage(with: nil)
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
            self.userPresenceStatus = LocalizedKeys.Common.online
        } else {
            let date = Date(timeIntervalSince1970: presence.lastSeen)
            let formatter = DateFormatter()
            formatter.doesRelativeDateFormatting = true
            
            if Calendar.current.isDateInToday(date) {
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                self.userPresenceStatus = LocalizedKeys.Chat.lastSeenToday(at: formatter.string(from: date))
            } else if Calendar.current.isDateInYesterday(date) {
                formatter.timeStyle = .short
                formatter.dateStyle = .none
                self.userPresenceStatus = LocalizedKeys.Chat.lastSeenYesterday(at: formatter.string(from: date))
            } else {
                formatter.timeStyle = .short
                formatter.dateStyle = .short
                self.userPresenceStatus = LocalizedKeys.Chat.lastSeenOnDate(formatter.string(from: date))
            }
        }
    }
    
    private func updateLocalMessage(withId id: String, finalMessage: Message) {
        if let index = messages.firstIndex(where: { $0.id == id }) {
            messages[index] = finalMessage
        }
    }
}
