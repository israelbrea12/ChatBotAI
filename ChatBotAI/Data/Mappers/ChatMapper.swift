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
    
    static func toData(_ data: [String: Any], chatId: String) -> ChatModel {
        let participants = data[Constants.Database.Chat.participants] as? [String] ?? []
        let createdAt = data[Constants.Database.Chat.createdAt] as? Double ?? 0
        
        var lastMessage: LastMessageModel? = nil
        
        if let lastMessageData = data[Constants.Database.Chat.lastMessage] as? [String: Any] {
            let text = lastMessageData[Constants.Database.Message.text] as? String
            let senderId = lastMessageData[Constants.Database.Message.senderId] as? String
            let sentAt = lastMessageData[Constants.Database.Message.sentAt] as? Double
            lastMessage = LastMessageModel(text: text ?? "", sentAt: sentAt ?? 0.0, senderId: senderId ?? "")
        }
        
        return ChatModel(
            id: chatId,
            participants: participants,
            createdAt: createdAt,
            lastMessage: lastMessage
        )
    }
}
