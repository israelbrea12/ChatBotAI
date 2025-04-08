//
//  MessageModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

struct MessageModel: Codable {
    var id: String
    var text: String
    var senderId: String
    var senderName: String
    var sentAt: TimeInterval
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case senderId
        case senderName
        case sentAt
    }
    
    init(id: String, text: String, senderId: String, senderName: String, sentAt: TimeInterval) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.sentAt = sentAt
    }
}

