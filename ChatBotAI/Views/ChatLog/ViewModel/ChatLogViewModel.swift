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

    private let sendMessageUseCase: SendMessageUseCase
    private var chatId: String?

    init(sendMessageUseCase: SendMessageUseCase) {
        self.sendMessageUseCase = sendMessageUseCase
    }

    func setupChat(currentUser: User, otherUser: User) {
        chatId = generateChatId(for: currentUser.id, and: otherUser.id)
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
}


