//
//  MessageBubbleView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 8/4/25.
//

import SwiftUI

struct MessageBubbleView: View {
    let message: Message
    let isCurrentUser: Bool

    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }

            VStack(alignment: .leading, spacing: 4) {
                Text(message.text)
                    .padding(10)
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            .frame(maxWidth: 250, alignment: isCurrentUser ? .trailing : .leading)

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}
