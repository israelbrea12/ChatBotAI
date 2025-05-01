//
//  ChatLogViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import Foundation

@MainActor
class ChatLogViewModel: ObservableObject {
    @Published var state: ViewState = .success
    @Published var chatText = ""
    @Published var messages: [Message] = []

    private let sendMessageUseCase: SendMessageUseCase
    private let fetchMessagesUseCase: FetchMessagesUseCase
    private let observeMessagesUseCase: ObserveMessagesUseCase
    
    private var chatId: String?

    init(
        sendMessageUseCase: SendMessageUseCase,
        fetchMessagesUseCase: FetchMessagesUseCase,
        observeMessagesUseCase: ObserveMessagesUseCase
    ) {
        self.sendMessageUseCase = sendMessageUseCase
        self.fetchMessagesUseCase = fetchMessagesUseCase
        self.observeMessagesUseCase = observeMessagesUseCase
    }

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

    private func generateChatId(for user1: String, and user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }

    func sendMessage(currentUser: User?) {
        guard let user = currentUser,
              let chatId = chatId,
              !chatText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        let message = Message(
            id: UUID().uuidString,
            text: chatText,
            senderId: user.id,
            senderName: user.fullName ?? ""
        )

        Task {
            print("\(chatId)")
            let result = await sendMessageUseCase.execute(
                with: SendMessageParams(chatId: chatId, message: message)
            )

            switch result {
            case .success:
                chatText = ""
            case .failure(let error):
                print("Error enviando mensaje: \(error.localizedDescription)")
                state = .error("Error al enviar el mensaje")
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
    }
}


