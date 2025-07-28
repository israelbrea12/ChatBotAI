//
//  EditingMessageBar.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 17/7/25.
//

import SwiftUI

struct EditingMessageBar: View {
    let message: Message
    let onCancel: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                VStack(alignment: .leading) {
                    Text(LocalizedKeys.Chat.editingMessageFrom(message.senderName))
                        .font(.caption)
                        .foregroundColor(.gray)
                    Text(message.text)
                        .font(.subheadline)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.secondary.opacity(0.1))
            .cornerRadius(10)
            .padding(.horizontal)
        }
    }
}
