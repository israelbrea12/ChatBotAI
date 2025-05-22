//
//  ChatBotIAViewModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import Foundation
import Combine
import SwiftUI // Para @MainActor

@MainActor
final class ChatBotIAViewModel: ObservableObject {

    @Published var prompt: String = ""
    @Published var messages: [ChatbotMessage] = []
    @Published var viewState: ViewState = .initial
    // 'isGenerating' y 'hasStartedChatting' pueden derivarse o integrarse en 'viewState'
    // Por simplicidad y para mantenerlo similar a tu código original, los mantenemos separados por ahora.
    @Published var isGenerating: Bool = false
    @Published var hasStartedChatting: Bool = false

    private let sendMessageToChatBotUseCase: SendMessageToChatBotUseCase

    init(sendMessageToChatBotUseCase: SendMessageToChatBotUseCase) {
        self.sendMessageToChatBotUseCase = sendMessageToChatBotUseCase
        // Considera añadir un mensaje de bienvenida si es necesario.
        // addInitialBotMessage(text: "Hola, ¿cómo puedo ayudarte hoy?")
    }

    private func addMessage(_ message: ChatbotMessage) {
        messages.append(message)
        if !hasStartedChatting {
            hasStartedChatting = true
        }
    }

    func sendMessage() {
        let currentPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !currentPrompt.isEmpty else { return }

        addMessage(ChatbotMessage(text: currentPrompt, isUser: true))
        self.prompt = "" // Limpiar el campo de texto

        self.isGenerating = true
        self.viewState = .loading

        Task {
            let params = SendMessageToChatBotParams(prompt: currentPrompt)
            let result = await sendMessageToChatBotUseCase.execute(with: params)

            self.isGenerating = false
            switch result {
            case .success(let aiResponseText):
                self.addMessage(ChatbotMessage(text: aiResponseText, isUser: false))
                self.viewState = .success
            case .failure(let error):
                let errorMessage = "Error: \(error.localizedDescription)"
                self.addMessage(ChatbotMessage(text: errorMessage, isUser: false))
                self.viewState = .error(errorMessage)
            }
        }
    }
}
