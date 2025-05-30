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
    private var currentStreamingTask: Task<Void, Never>?

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

    func sendMessage() {
            let userText = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !userText.isEmpty else { return }

            addMessage(ChatbotMessage(text: userText, isUser: true))
            let currentPrompt = self.prompt // Guardar antes de limpiar
            self.prompt = ""
            
            let promptToSend: String
            switch chatMode {
            case .rolePlay:
                // Si el chat ya ha comenzado, el `chatMode.initialPrompt` (setup del roleplay)
                // ya debería estar en el historial del modelo o ser gestionado por el modelo.
                // Para las siguientes interacciones, solo envías el texto del usuario.
                // Si es el PRIMER mensaje en modo RolePlay después de la configuración,
                // el `chatMode.initialPrompt` (que contiene la configuración del roleplay)
                // DEBE enviarse JUNTO con el primer mensaje del usuario o como contexto inicial.
                // La lógica aquí depende de cómo tu `GenerativeModel` maneja el historial de chat.
                // Si `chatMode.initialPrompt` es una instrucción de sistema:
                // Lo ideal es que `sendMessageToModel` lo gestione adecuadamente,
                // quizá enviándolo como parte del historial o contexto al modelo.
                // Si es la primera vez en roleplay, el prompt inicial puede ser más complejo.
                if !hasStartedChatting || messages.filter({ $0.isUser }).count == 1 { // Asumiendo que este es el primer mensaje del usuario después del setup
                     promptToSend = "\(chatMode.initialPrompt)\n\nUsuario: \(userText)"
                } else {
                     promptToSend = userText // O "Usuario: \(userText)" si el modelo lo espera así
                }

            default: // Classic, textImprovement, grammarHelp
                // Para estos modos, el initialPrompt actúa como una instrucción de sistema o prefijo.
                // Considera si el initialPrompt debe enviarse cada vez o solo al inicio.
                // Si el modelo mantiene el contexto, solo el userText es necesario después del primer turno.
                // Para simplificar y ser robusto, lo incluimos (el modelo debería poder manejarlo).
                promptToSend = "\(chatMode.initialPrompt)\n\nInput del Usuario: \(userText)"
            }
            
            // Cancelar cualquier tarea de streaming anterior
            currentStreamingTask?.cancel()
            sendMessageToModel(prompt: promptToSend)
        }

    private func sendMessageToModel(prompt: String) {
            self.isGenerating = true
            self.viewState = .loading
            // Añadir un mensaje de bot vacío que se irá llenando
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
                        fullResponseReceived = true // Marcamos que al menos un chunk llegó
                    }
                    if Task.isCancelled {
                        // Si se canceló, el último mensaje podría estar incompleto.
                        // Podrías añadir "[Cancelado]" o dejarlo como está.
                        if !messages.isEmpty && !messages.last!.isUser && messages.last!.text.isEmpty {
                            messages.removeLast() // Elimina el placeholder si no se recibió nada
                        } else if !messages.isEmpty && !messages.last!.isUser {
                            // Opcional: añadir indicación de cancelación al mensaje parcial
                            // messages[messages.count - 1].text += " [Cancelado]"
                        }
                         print("Streaming task cancelled.")
                    } else if fullResponseReceived {
                        self.viewState = .success
                    } else {
                        // Stream terminó sin chunks, podría ser un error silencioso o prompt vacío al modelo
                        // Eliminar el placeholder si no se recibió nada
                        if !messages.isEmpty && !messages.last!.isUser && messages.last!.text.isEmpty {
                            messages.removeLast()
                        }
                        self.viewState = .error("La IA no generó respuesta.")
                         // Opcional: añadir mensaje de error
                        // self.addMessage(ChatbotMessage(text: "La IA no generó respuesta.", isUser: false))
                    }
                } catch {
                    if Task.isCancelled {
                        print("Streaming task cancelled before error handling.")
                         if !messages.isEmpty && !messages.last!.isUser && messages.last!.text.isEmpty {
                            messages.removeLast() // Elimina el placeholder si no se recibió nada
                        }
                        return // Salir si la tarea fue cancelada
                    }
                    let errorMessage = "Error: \(error.localizedDescription)"
                    // Actualizar el último mensaje (que era el placeholder del bot) con el error
                    if let lastMessageIndex = messages.lastIndex(where: { !$0.isUser }) {
                        if messages[lastMessageIndex].text.isEmpty { // Si estaba vacío, poner el error
                            messages[lastMessageIndex].text = errorMessage
                        } else { // Si ya tenía texto (parcial) y luego dio error, añadir el error
                            messages[lastMessageIndex].text += "\n\(errorMessage)"
                        }
                    } else { // Si por alguna razón no hay mensaje de bot, añadir uno nuevo con el error
                        self.addMessage(ChatbotMessage(text: errorMessage, isUser: false))
                    }
                    self.viewState = .error(error.localizedDescription)
                }
                
                self.isGenerating = false
            }
        }
        
        // Opcional: Para cancelar el stream si el usuario navega fuera, etc.
        func cancelStreaming() {
            currentStreamingTask?.cancel()
            self.isGenerating = false // Asegurarse de resetear el estado
            // Considera si necesitas actualizar el viewState aquí también
        }
}
