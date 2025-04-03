//
//  Chat.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

struct Chat: Identifiable, Codable {
    let id: String
    let participants: [String]
    let createdAt: TimeInterval?
    let lastMessageText: String?
    let lastMessageSenderId: String?
    let lastMessageTimestamp: TimeInterval?
}
