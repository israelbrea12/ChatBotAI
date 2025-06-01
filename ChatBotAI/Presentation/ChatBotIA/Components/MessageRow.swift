//
//  MessageRow.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import SwiftUI

// Subvista para la fila del mensaje
struct MessageRow: View {
    
    let message: ChatbotMessage

    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
                MessageBubble(text: message.text, backgroundColor: Color(.systemGray5), textColor: .primary)
            } else {
                MessageBubble(text: message.text, backgroundColor: Color.blue.opacity(0.2), textColor: .primary, leadingIconName: "brain.head.profile")
                Spacer()
            }
        }
    }
}
