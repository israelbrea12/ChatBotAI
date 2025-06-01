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
    @Published var isUploadingImage: Bool = false

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

                    // Añade el nuevo mensaje si aún no está en la lista
                    if !self.messages.contains(where: { $0.id == newMessage.id }) {
                        self.messages.append(newMessage)
                    }
                }
            }
        }
    }

    func sendTextMessage(currentUser: User?) { // Renombrado para claridad
        guard let user = currentUser,
              let chatId = chatId else {
            return
        }
        
        let trimmedText = chatText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else {
            return
        }
        
        let message = Message(
            id: UUID().uuidString, // El ID debería generarse en el backend o ser único
            text: trimmedText,
            senderId: user.id,
            senderName: user.fullName ?? "",
            sentAt: Date().timeIntervalSince1970, // Añade el timestamp aquí
            messageType: .text // Especifica el tipo
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
    
    func sendImageMessage(imageData: Data, currentUser: User?, caption: String = "") { // Añadido caption opcional
        guard let user = currentUser, let chatId = chatId else {
            print("Error: Usuario o chatId no disponible.")
            // Podrías establecer state = .error aquí si quieres que la UI reaccione
            return
        }
        
        self.isUploadingImage = true // Mostrar indicador de carga
        let messageId = UUID().uuidString // ID único para el mensaje y para la ruta de la imagen
        
        Task {
            let uploadParams = UploadImageParams(imageData: imageData, chatId: chatId, messageId: messageId)
            let uploadResult = await self.uploadImageUseCase.execute(with: uploadParams)
            
            switch uploadResult {
            case .success(let imageURL):
                // Imagen subida, ahora envía el mensaje a Realtime Database
                let message = Message(
                    id: messageId,
                    text: caption, // Usa el caption
                    senderId: user.id,
                    senderName: user.fullName ?? "",
                    sentAt: Date().timeIntervalSince1970,
                    messageType: .image,
                    imageURL: imageURL.absoluteString
                )
                
                let sendMessageParams = SendMessageParams(chatId: chatId, message: message)
                let sendResult = await self.sendMessageUseCase.execute(with: sendMessageParams)
                
                self.isUploadingImage = false // Ocultar indicador de carga
                
                switch sendResult {
                case .success:
                    print("Mensaje de imagen enviado exitosamente a RTDB.")
                    // No es necesario cambiar el `state` si ya es `.success` o `.empty`
                case .failure(let error):
                    print("Error enviando mensaje de imagen a RTDB: \(error.localizedDescription)")
                    self.state = .error("Error al enviar la imagen: \(error.localizedDescription)")
                }
                
            case .failure(let error):
                self.isUploadingImage = false // Ocultar indicador de carga
                print("Error al subir la imagen a Firebase Storage: \(error.localizedDescription)")
                self.state = .error("No se pudo subir la imagen: \(error.localizedDescription)")
            }
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
