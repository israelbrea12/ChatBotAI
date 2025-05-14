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

            ZStack(alignment: .bottomTrailing) {
                Text(message.text)
                    .padding(.all, 10)
                    .padding(.trailing, 40) // deja espacio para la hora
                    .foregroundColor(isCurrentUser ? .white : .black)
                    .background(isCurrentUser ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(12)
                    .fixedSize(horizontal: false, vertical: true)

                if let sentAt = message.sentAt {
                    Text(Date(timeIntervalSince1970: sentAt).BublesFormattedTime())
                        .font(.caption2)
                        .foregroundColor(isCurrentUser ? .white.opacity(0.8) : .gray)
                        .padding([.bottom, .trailing], 6)
                }
            }
            .frame(maxWidth: UIScreen.main.bounds.width * 0.85, alignment: isCurrentUser ? .trailing : .leading)

            if !isCurrentUser { Spacer() }
        }
        .padding(.horizontal)
        .padding(.top, 4)
    }
}

