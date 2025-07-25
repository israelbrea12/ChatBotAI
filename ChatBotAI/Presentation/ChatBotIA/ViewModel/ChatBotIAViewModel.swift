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

    // MARK: - Publisheds
    @Published var prompt: String = ""
    @Published var messages: [ChatbotMessage] = []
    @Published var viewState: ViewState = .initial
    // 'isGenerating' y 'hasStartedChatting' pueden derivarse o integrarse en 'viewState'
    // Por simplicidad y para mantenerlo similar a tu código original, los mantenemos separados por ahora.
    @Published var isGenerating: Bool = false
    @Published var hasStartedChatting: Bool = false

    // MARK: - Private vars
    private(set) var chatMode: ChatMode
    private var currentStreamingTask: Task<Void, Never>?
    private var userLearningLanguage: Language {
        guard let langCode = SessionManager.shared.currentUser?.learningLanguage,
              let language = Language(rawValue: langCode) else {
            return .english
        }
        return language
    }
    
    // MARK: - Computed Properties for UI
    var currentNavigationTitle: String {
        chatMode.titleForChatView
    }

    var currentPlaceholderSubtitle: String {
        chatMode.subtitleForChatView
    }
    
    // MARK: - Use Cases
    private let sendMessageToChatBotUseCase: SendMessageToChatBotUseCase

    // MARK: - Lifecycle functions
    init(sendMessageToChatBotUseCase: SendMessageToChatBotUseCase, chatMode: ChatMode) {
        self.sendMessageToChatBotUseCase = sendMessageToChatBotUseCase
        // Considera añadir un mensaje de bienvenida si es necesario.
        // addInitialBotMessage(text: "Hola, ¿cómo puedo ayudarte hoy?")
        self.chatMode = chatMode
        self.startChatWithInitialPrompt()
    }
    
    // MARK: - Functions
    func sendMessage() {
        let userText = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !userText.isEmpty else { return }
        
        addMessage(ChatbotMessage(text: userText, isUser: true))
        self.prompt = ""
        
        let promptToSend: String
        
        let language = self.userLearningLanguage
        
        switch chatMode {
        case .rolePlay:
            if !hasStartedChatting || messages.filter({ $0.isUser }).count == 1 {
                promptToSend = "\(chatMode.initialPrompt(language: language))\n\nUsuario: \(userText)"
            } else {
                promptToSend = userText
            }
            
        default:
            promptToSend = "\(chatMode.initialPrompt(language: language))\n\nInput del Usuario: \(userText)"
        }
        currentStreamingTask?.cancel()
        sendMessageToModel(prompt: promptToSend)
    }
    
    func cancelStreaming() {
        currentStreamingTask?.cancel()
        self.isGenerating = false
    }

    
    // MARK: - Private Functions
    private func startChatWithInitialPrompt() {
        let language = self.userLearningLanguage
        
        switch chatMode {
        case .rolePlay:
            let initialMessage = chatMode.initialPrompt(language: language)
            addMessage(ChatbotMessage(text: initialMessage, isUser: true))
            sendMessageToModel(prompt: initialMessage)
        case .classicConversation, .textImprovement, .grammarHelp:
            break
        }
    }

    private func addMessage(_ message: ChatbotMessage) {
        messages.append(message)
        if !hasStartedChatting {
            hasStartedChatting = true
        }
    }
    
    private func updateLastBotMessage(with chunk: String) {
        guard let lastMessage = messages.last, !lastMessage.isUser else {
            addMessage(ChatbotMessage(text: chunk, isUser: false))
            return
        }
        
        let lastMessageIndex = messages.count - 1
        messages[lastMessageIndex].text += chunk
    }

    private func sendMessageToModel(prompt: String) {
        self.isGenerating = true
        self.viewState = .loading
        let botMessagePlaceholder = ChatbotMessage(text: "", isUser: false)
        self.addMessage(botMessagePlaceholder)
        
        currentStreamingTask = Task {
            let params = SendMessageToChatBotParams(prompt: prompt)
            print("Streaming prompt: \(prompt)")
            
            let stream = sendMessageToChatBotUseCase.executeStream(with: params)
            var fullResponseReceived = false
            
            do {
                for try await chunk in stream {
                    if Task.isCancelled { break }
                    updateLastBotMessage(with: chunk)
                    fullResponseReceived = true
                }
                if Task.isCancelled {
                    if !messages.isEmpty && !messages.last!.isUser && messages.last!.text.isEmpty {
                        messages.removeLast()
                    } else if !messages.isEmpty && !messages.last!.isUser {
                        // Opcional: añadir indicación de cancelación al mensaje parcial
                        // messages[messages.count - 1].text += " [Cancelado]"
                    }
                    print("Streaming task cancelled.")
                } else if fullResponseReceived {
                    self.viewState = .success
                } else {
                    if !messages.isEmpty && !messages.last!.isUser && messages.last!.text.isEmpty {
                        messages.removeLast()
                    }
                    self.viewState = .error("La IA no generó respuesta.")
                }
            } catch {
                if Task.isCancelled {
                    print("Streaming task cancelled before error handling.")
                    if !messages.isEmpty && !messages.last!.isUser && messages.last!.text.isEmpty {
                        messages.removeLast()
                    }
                    return
                }
                let errorMessage = "Error: \(error.localizedDescription)"

                if let lastMessageIndex = messages.lastIndex(where: { !$0.isUser }) {
                    if messages[lastMessageIndex].text.isEmpty {
                        messages[lastMessageIndex].text = errorMessage
                    } else {
                        messages[lastMessageIndex].text += "\n\(errorMessage)"
                    }
                } else {
                    self.addMessage(ChatbotMessage(text: errorMessage, isUser: false))
                }
                self.viewState = .error(error.localizedDescription)
            }
            
            self.isGenerating = false
        }
    }
}
