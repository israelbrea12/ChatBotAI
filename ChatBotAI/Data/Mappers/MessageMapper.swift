//
//  MessageMapper.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation

extension MessageModel {
    func toDomain() -> Message {
        return Message(id: self.id, text: self.text, senderId: self.senderId, senderName: self.senderName, sentAt: self.sentAt)
    }
}
