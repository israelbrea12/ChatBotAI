//
//  ChatBotIAView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

// Presentation/ChatBotIA/View/ChatBotIAView.swift
import SwiftUI

struct ChatBotIAView: View {
    
    @StateObject var chatBotIAViewModel = Resolver.shared.resolve(ChatBotIAViewModel.self)

    var body: some View {
        VStack(spacing: 0) {
            if !chatBotIAViewModel.hasStartedChatting && chatBotIAViewModel.messages.isEmpty {
                Text("¿En qué puedo ayudarte?")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.top)
            }

            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack(spacing: 8) { // Añadido spacing para los mensajes
                        ForEach(chatBotIAViewModel.messages) { message in
                            MessageRow(message: message)
                                .id(message.id) // Asegúrate que el ID es usado por el ScrollViewReader
                        }
                    }
                    .padding(.horizontal) // Padding horizontal para el contenido del ScrollView
                    .padding(.top, 10) // Espacio arriba de los mensajes
                    .onChange(of: chatBotIAViewModel.messages) { oldValue, newValue in
                        // Usar el último mensaje de la nueva lista
                        if let lastMessageId = newValue.last?.id {
                            withAnimation { // Animación suave para el scroll
                                scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ocupa el espacio disponible

            // Muestra errores de forma no intrusiva si es necesario
            if case .error(let errorMessage) = chatBotIAViewModel.viewState {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .font(.caption)
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.1))
            }
            
            MessageInputView(
                prompt: $chatBotIAViewModel.prompt,
                isGenerating: chatBotIAViewModel.isGenerating,
                sendMessageAction: chatBotIAViewModel.sendMessage
            )
        }
        // .navigationTitle("ChatBot AI") // Si está dentro de un NavigationStack
        // .navigationBarTitleDisplayMode(.inline)
    }
}
