//
//  MessageInputView.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import SwiftUI

struct MessageInputView: View {
    
    @Binding var prompt: String
    
    let isGenerating: Bool
    let sendMessageAction: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            TextField(LocalizedKeys.Placeholder.typeYourMessage, text: $prompt, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemGray6))
                )
                .lineLimit(1...5)
            
            Button(action: {
                sendMessageAction()
            }) {
                if isGenerating {
                    ProgressView()
                        .frame(width: 28, height: 28) 
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        .foregroundColor(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .gray : .blue)
                }
            }
            .disabled(prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isGenerating)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color(.systemBackground).ignoresSafeArea(.container, edges: .bottom))
    }
}
