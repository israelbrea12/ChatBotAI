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
            HStack(spacing: 12) {
                
                Image(systemName: "photo.on.rectangle")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                
                ZStack {
                    DescriptionPlaceholder()
                    TextEditor(text: $chatText)
                        .opacity(chatText.isEmpty ? 0.5 : 1)
                        .submitLabel(.next)
                }
                .frame(height: 40)
                
                Button(action: {
                    onSendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .rotationEffect(.degrees(45))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color.white)
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
