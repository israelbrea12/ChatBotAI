//
//  ChatBotIAView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 12/3/25.
//

import SwiftUI
import GoogleGenerativeAI

struct ChatBotIAView: View {
    @State private var prompt: String = ""
    @State private var messages: [ChatbotMessage] = []
    @State private var isGenerating: Bool = false
    @State private var hasStartedChatting: Bool = false // Nueva variable de estado

    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)

    var body: some View {
        VStack(spacing: 0) { // Espacio entre elementos a 0 para que parezcan más unidos
            if !hasStartedChatting {
                Text("¿En qué puedo ayudarte?")
                    .font(.title2)
                    .padding(.top)
            }

            ScrollView {
                ScrollViewReader { scrollViewProxy in
                    VStack {
                        ForEach(messages) { message in
                            if message.isUser {
                                HStack {
                                    Spacer()
                                    Text(message.text)
                                        .padding()
                                        .background(Color(.systemGray5))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            } else {
                                HStack(alignment: .top) {
                                    Image(systemName: "brain.head.profile") // Un icono para la IA
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding(.trailing, 4)
                                        .padding(.top, 8)
                                    Text(message.text)
                                        .padding()
                                        .background(Color(.systemBlue).opacity(0.2))
                                        .foregroundColor(.primary)
                                        .cornerRadius(10)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .onChange(of: messages) {
                        // Desplazar al último mensaje cuando la lista de mensajes cambia
                        if let lastMessageId = messages.last?.id {
                            scrollViewProxy.scrollTo(lastMessageId, anchor: .bottom)
                        }
                    }
                }
            }
            .frame(maxHeight: .infinity) // El ScrollView ocupa todo el espacio vertical disponible

            HStack {
                TextField("Escribe tu mensaje...", text: $prompt)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button {
                    Task {
                        await sendMessage(currentPrompt: prompt)
                    }
                } label: {
                    if isGenerating {
                        ProgressView()
                    } else {
                        Text("Enviar")
                    }
                }
                .disabled(isGenerating || prompt.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
            .background(Color(.systemBackground).ignoresSafeArea(edges: .bottom)) // Añadir un fondo al área de entrada
        }
    }

    func sendMessage(currentPrompt: String) async {
        guard !currentPrompt.isEmpty else { return }

        let userMessage = ChatbotMessage(text: currentPrompt, isUser: true)
        messages.append(userMessage)
        prompt = ""
        hasStartedChatting = true // Marcamos que el chat ha comenzado

        isGenerating = true
        do {
            let result = try await model.generateContent(currentPrompt)
            if let text = result.text {
                let aiMessage = ChatbotMessage(text: text, isUser: false)
                messages.append(aiMessage)
            }
        } catch {
            let errorMessage = ChatbotMessage(text: "Error al obtener la respuesta: \(error.localizedDescription)", isUser: false)
            messages.append(errorMessage)
        }
        isGenerating = false
    }
}

struct ChatbotMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
}

#Preview {
    ChatBotIAView()
}
