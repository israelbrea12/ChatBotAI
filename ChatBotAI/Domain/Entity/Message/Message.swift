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
    var messageType: MessageType = .text
    var imageURL: String? = nil


    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id &&
        lhs.text == rhs.text &&
        lhs.senderId == rhs.senderId &&
        lhs.senderName == rhs.senderName &&
        lhs.sentAt == rhs.sentAt &&
        lhs.messageType == rhs.messageType &&
        lhs.imageURL == rhs.imageURL
    }
}
