//
//  ChatModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

struct ChatModel: Codable {
    let id: String
    let participants: [String]
    let createdAt: TimeInterval?
    let lastMessage: LastMessageModel?
    
    enum CodingKeys: String, CodingKey {
        case id
        case participants
        case createdAt
        case lastMessage
    }
    
    init(
        id: String,
        participants: [String],
        createdAt: TimeInterval?,
        lastMessage: LastMessageModel?
    ) {
        self.id = id
        self.participants = participants
        self.createdAt = createdAt
        self.lastMessage = lastMessage
    }
}
