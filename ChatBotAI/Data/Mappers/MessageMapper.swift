//
//  MessageMapper.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

extension MessageModel {
    func toDomain() -> Message {
        return Message(
            id: self.id,
            text: self.text,
            senderId: self.senderId,
            senderName: self.senderName,
            sentAt: self.sentAt,
            messageType: MessageType(rawValue: self.messageType) ?? .text,
            imageURL: self.imageURL,
            replyTo: self.replyTo,
            isEdited: self.isEdited ?? false
        )
    }
}

extension Message {
    func toFirebaseData() -> [String: Any] {
        var data: [String: Any] = [
            Constants.Database.Message.id: self.id,
            Constants.Database.Message.text: self.text,
            Constants.Database.Message.senderId: self.senderId,
            Constants.Database.Message.senderName: self.senderName,
            Constants.Database.Message.sentAt: self.sentAt ?? Date().timeIntervalSince1970,
            Constants.Database.Message.messageType: self.messageType.rawValue
        ]
        if let imageURL = self.imageURL {
            data[Constants.Database.Message.imageURL] = imageURL
        }
        if self.isEdited {
            data[Constants.Database.Message.isEdited] = true
        }
        if let replyTo = self.replyTo {
            data[Constants.Database.Message.replyTo] = replyTo
        }
        return data
    }
}
