//
//  ChatMapper.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 3/4/25.
//

import Foundation

extension ChatModel {
    func toDomain() -> Chat {
        return Chat(
            id: self.id,
            participants: self.participants,
            createdAt: self.createdAt,
            lastMessageText: self.lastMessage?.text,
            lastMessageSenderId: self.lastMessage?.senderId,
            lastMessageTimestamp: self.lastMessage?.sentAt
        )
    }
}
