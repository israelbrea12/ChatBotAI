//
//  LastMessageModel.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

struct LastMessageModel: Codable {
    let text: String
    let sentAt: TimeInterval
    let senderId: String

    enum CodingKeys: String, CodingKey {
        case text
        case sentAt
        case senderId
    }
    
    init(text: String, sentAt: TimeInterval, senderId: String) {
        self.text = text
        self.sentAt = sentAt
        self.senderId = senderId
    }
}
