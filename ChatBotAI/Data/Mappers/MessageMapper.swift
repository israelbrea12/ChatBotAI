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
            isEdited: self.isEdited ?? false
        )
    }
}

extension Message {
    func toFirebaseData() -> [String: Any] {
        var data: [String: Any] = [
            "id": self.id,
            "text": self.text,
            "senderId": self.senderId,
            "senderName": self.senderName,
            "sentAt": self.sentAt ?? Date().timeIntervalSince1970,
            "messageType": self.messageType.rawValue
        ]
        if let imageURL = self.imageURL {
            data["imageURL"] = imageURL
        }
        if self.isEdited {
            data["isEdited"] = true
        }
        return data
    }
}
