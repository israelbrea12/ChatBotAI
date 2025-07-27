//
//  ReplyingToMessageBar.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 27/7/25.
//


// ReplyingToMessageBar.swift

import SwiftUI

struct ReplyingToMessageBar: View {
    let message: Message
    let onCancel: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Capsule()
                .fill(Color.blue)
                .frame(width: 4)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Respondiendo a \(message.senderName)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                
                Text(message.messageType == .image ? (message.text.isEmpty ? "Imagen" : message.text) : message.text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            
            Spacer()
            
            Button(action: onCancel) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding(8)
        .frame(height: 50)
        .background(.thinMaterial)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}