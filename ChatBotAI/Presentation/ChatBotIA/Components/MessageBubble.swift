//
//  MessageBubble.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 15/5/25.
//

import SwiftUI

// Subvista para la burbuja del mensaje
struct MessageBubble: View {
    let text: String
    let backgroundColor: Color
    let textColor: Color
    var leadingIconName: String? = nil

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            if let iconName = leadingIconName {
                Image(systemName: iconName)
                    .font(.title3) // Ajusta según sea necesario
                    .foregroundColor(textColor.opacity(0.8))
                    .padding(.top, 2) // Alineación fina con el texto
            }
            Text(text)
                .padding(12)
                .foregroundColor(textColor)
                .background(backgroundColor)
                .cornerRadius(16)
        }
    }
}
