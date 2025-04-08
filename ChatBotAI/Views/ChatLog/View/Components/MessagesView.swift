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
    
    var body: some View {
            ScrollView {
                LazyVStack {
                    ForEach(messages) { message in
                        MessageBubbleView(message: message, isCurrentUser: message.senderId != currentUserId)
                    }
                }
                .padding(.vertical, 8)
            }
            .background(Color(.init(white: 0.95, alpha: 1)))
        }
}
