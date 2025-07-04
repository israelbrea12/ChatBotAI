//
//  MessageBubble.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import SwiftUI
import MarkdownUI

struct MessageBubble: View {
    
    let text: String
    let backgroundColor: Color
    let textColor: Color
    var leadingIconName: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if let iconName = leadingIconName {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundColor(textColor.opacity(0.8))
                    .padding(.top, 2)
            }

            Markdown(text)
                .padding(12)
                .background(backgroundColor)
                .cornerRadius(16)
        }
    }
}

