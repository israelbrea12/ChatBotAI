//
//  Message.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

struct Message: Identifiable, Codable, Equatable {
    var id: String
    var text: String
    var senderId: String
    var senderName: String
    var sentAt: TimeInterval?
}
