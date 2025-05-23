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
    
    private(set) var chatMode: ChatMode

    init(sendMessageToChatBotUseCase: SendMessageToChatBotUseCase, chatMode: ChatMode) {
        self.sendMessageToChatBotUseCase = sendMessageToChatBotUseCase
        // Considera añadir un mensaje de bienvenida si es necesario.
        // addInitialBotMessage(text: "Hola, ¿cómo puedo ayudarte hoy?")
        self.chatMode = chatMode
        self.startChatWithInitialPrompt()
    }
    
    private func startChatWithInitialPrompt() {
            switch chatMode {
            case .rolePlay: // El prompt se pasa en el primer mensaje
                addMessage(ChatbotMessage(text: chatMode.initialPrompt, isUser: true))
                sendMessageToModel(prompt: chatMode.initialPrompt)
            case .basicCorrection, .advancedCorrection, .grammarHelp:
                break // Espera a que el usuario introduzca el texto
            }
        }

    private func addMessage(_ message: ChatbotMessage) {
        messages.append(message)
        if !hasStartedChatting {
            hasStartedChatting = true
        }
    }

    func sendMessage() {
            let userText = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !userText.isEmpty else { return }

            addMessage(ChatbotMessage(text: userText, isUser: true))
            self.prompt = ""
            self.isGenerating = true
            self.viewState = .loading

            let promptToSend: String
            switch chatMode {
            case .rolePlay:
                promptToSend = userText
            default:
                promptToSend = "\(chatMode.initialPrompt)\n\(userText)"
            }

            sendMessageToModel(prompt: promptToSend)
        }

        private func sendMessageToModel(prompt: String) {
            Task {
                let params = SendMessageToChatBotParams(prompt: prompt)
                print("Prompt: \(prompt)")
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
