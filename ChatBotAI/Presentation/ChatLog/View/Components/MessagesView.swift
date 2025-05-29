//
//  MessagesView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct MessagesView: View {
    let messages: [Message]
    let currentUserId: String?
    
    @Namespace private var bottomID

    var groupedMessages: [(date: String, messages: [Message])] {
        Dictionary(grouping: messages) { message in
            guard let timestamp = message.sentAt else { return "Desconocido" }
            let date = Date(timeIntervalSince1970: timestamp)
            return date.whatsappFormattedTimeAgoWithoutAMOrPM()
        }
        .map { (key: String, value: [Message]) in
            (date: key, messages: value)
        }
        .sorted { a, b in
            guard
                let firstDate = a.messages.first?.sentAt,
                let secondDate = b.messages.first?.sentAt
            else { return false }
            return firstDate < secondDate
        }
    }

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(groupedMessages, id: \.date) { group in
                        Text(group.date)
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.gray.opacity(0.2)))
                        
                        ForEach(group.messages) { message in
                            MessageBubbleView(
                                message: message,
                                isCurrentUser: message.senderId == currentUserId,
                                onLongPress: {
                                    print("Mensaje con ID \(message.id) fue presionado largo.")
                                    // Aquí puedes más adelante mostrar un menú, alertas, etc.
                                })
                            .id(message.id)
                            .padding(.bottom, group.messages.last?.id == message.id ? 5 : 0)
                        }
                    }
                    Color.clear
                        .frame(height: 1)
                        .id(bottomID)
                }
                .padding(.vertical, 8)
            }
            .simultaneousGesture(
                DragGesture().onChanged { _ in
                    UIApplication.shared.endEditing()
                }
            )
            .background(Color(.init(white: 0.95, alpha: 1)))
            .onAppear {
                DispatchQueue.main
                    .asyncAfter(
                        deadline: .now() + 0.05
                    ) {
                        scrollToBottom(proxy: scrollViewProxy, animated: false)
                    }
            }
            .onChange(of: messages.count) {
                scrollToBottom(proxy: scrollViewProxy)
            }
            .onChange(of: messages.last?.id) {
                scrollToBottom(proxy: scrollViewProxy)
            }
        }
    }
    
    // Función helper para hacer scroll al fondo
    private func scrollToBottom(proxy: ScrollViewProxy, animated: Bool = true) {
        guard !messages.isEmpty else {
            return
        }
        if animated {
            withAnimation(.spring()) { // Puedes ajustar la animación
                proxy.scrollTo(bottomID, anchor: .bottom)
            }
        } else {
            proxy.scrollTo(bottomID, anchor: .bottom)
        }
    }
}

