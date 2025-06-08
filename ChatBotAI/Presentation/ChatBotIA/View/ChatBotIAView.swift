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
        ZStack {
            Color.clear // Tu fondo actual
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }
            
            VStack(spacing: 0) {
                // ... (tu lógica de "En qué puedo ayudarte?")
                if !chatBotIAViewModel.hasStartedChatting && chatBotIAViewModel.messages.isEmpty {
                                        VStack(spacing: 8) {
                                            Text(chatBotIAViewModel.currentNavigationTitle) // Título del modo
                                                .font(.title2)
                                                .fontWeight(.semibold)
                                                .multilineTextAlignment(.center)
                                            
                                            Text(chatBotIAViewModel.currentPlaceholderSubtitle) // Subtítulo del modo
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                                .multilineTextAlignment(.center)
                                                .padding(.horizontal)
                                        }
                                        .padding(.top)
                                        .padding(.bottom) // Añade un poco de espacio antes de la lista de mensajes si esta apareciera justo después
                                    }
                
                
                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack(spacing: 8) {
                            ForEach(chatBotIAViewModel.messages) { message in
                                MessageRow(message: message) // MessageRow se actualizará si message.text cambia
                                    .id(message.id)
                                    .padding(.bottom, message.id == chatBotIAViewModel.messages.last?.id && chatBotIAViewModel.isGenerating ? 2 : 0) // Pequeño padding extra si es el último y está generando
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .onChange(of: chatBotIAViewModel.messages.last?.text) { _, _ in // Observar cambios en el texto del último mensaje
                            if let lastMessageId = chatBotIAViewModel.messages.last?.id {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                        .onChange(of: chatBotIAViewModel.messages.count) { _, _ in // También al añadir nuevo mensaje
                            if let lastMessageId = chatBotIAViewModel.messages.last?.id {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // ... (tu lógica de error)
                if case .error(let errorMessage) = chatBotIAViewModel.viewState, !chatBotIAViewModel.isGenerating { // Mostrar error solo si no está generando activamente
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
                    isGenerating: chatBotIAViewModel.isGenerating, // Esto mostrará el progress en la flecha
                    sendMessageAction: chatBotIAViewModel.sendMessage
                )
            }
        }
        .toolbarBackground(
            .visible,
            for: .navigationBar
        )
        .toolbarBackground(
            .ultraThinMaterial,
            for: .navigationBar
        )
        .onDisappear {
            // Opcional: Cancelar el stream si la vista desaparece
            // chatBotIAViewModel.cancelStreaming()
        }
    }
}

