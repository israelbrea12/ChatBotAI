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
    var messageType: String
    var imageURL: String?
    var isEdited: Bool?
    var replyTo: String?

    enum CodingKeys: String, CodingKey {
        case id
        case text
        case senderId
        case senderName
        case sentAt
        case messageType
        case imageURL
        case isEdited
        case replyTo
    }

    init(id: String, text: String, senderId: String, senderName: String, sentAt: TimeInterval, messageType: String, imageURL: String? = nil, isEdited: Bool = false, replyTo: String? = nil) {
        self.id = id
        self.text = text
        self.senderId = senderId
        self.senderName = senderName
        self.sentAt = sentAt
        self.messageType = messageType
        self.imageURL = imageURL
        self.isEdited = isEdited
        self.replyTo = replyTo
    }
}

