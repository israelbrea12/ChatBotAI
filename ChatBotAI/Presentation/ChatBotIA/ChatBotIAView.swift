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
            // Fondo invisible para detectar taps y cerrar el teclado
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    UIApplication.shared.endEditing()
                }

            VStack(spacing: 0) {
                if !chatBotIAViewModel.hasStartedChatting && chatBotIAViewModel.messages.isEmpty {
                    Text("¿En qué puedo ayudarte?")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }

                ScrollView {
                    ScrollViewReader { scrollViewProxy in
                        VStack(spacing: 8) {
                            ForEach(chatBotIAViewModel.messages) { message in
                                MessageRow(message: message)
                                    .id(message.id)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .onChange(of: chatBotIAViewModel.messages) { oldValue, newValue in
                            if let lastMessageId = newValue.last?.id {
                                withAnimation {
                                    scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

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
        }
    }
}
