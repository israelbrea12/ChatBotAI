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
            
            ZStack(alignment: .leading) {
                if chatText.isEmpty {
                    Text("Description")
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                
                TextField("", text: $chatText)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(20)
            }
            
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

