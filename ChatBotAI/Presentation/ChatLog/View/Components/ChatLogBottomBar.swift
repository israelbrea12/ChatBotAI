//
//  ChatLogBottomBar.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 26/3/25.
//

import SwiftUI

struct ChatLogBottomBar: View {
    
    @Binding var chatText: String
    var onSendMessage: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "photo.on.rectangle")
                .font(.system(size: 24))
                .foregroundColor(Color(.darkGray))
            ZStack {
                DescriptionPlaceholder()
                TextEditor(text: $chatText)
                    .opacity(chatText.isEmpty ? 0.5 : 1)
            }
            .frame(height: 40)
            
            Button {
                onSendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .rotationEffect(.degrees(45))
                    .foregroundColor(.white)
                    .offset(x: -1.5, y: 0)
            }
            .padding(6)
            .background(Color.blue)
            .clipShape(.circle)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}

private struct DescriptionPlaceholder: View {
    var body: some View {
        HStack {
            Text("Description")
                .foregroundColor(Color(.gray))
                .font(.system(size: 17))
                .padding(.leading, 5)
                .padding(.top, -4)
            Spacer()
        }
    }
}
