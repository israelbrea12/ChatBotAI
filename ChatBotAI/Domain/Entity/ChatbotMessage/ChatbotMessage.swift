//
//  Message.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

struct ChatbotMessage: Identifiable, Codable, Equatable {
    var id = UUID()
    var text: String
    var isUser: Bool
}
