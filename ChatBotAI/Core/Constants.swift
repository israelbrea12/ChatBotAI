//
//  Constants.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 18/6/25.
//

import Foundation

enum Constants {
    
    enum AppName {
        static let appName = "ChatBot AI"
    }
    
    enum AI {
        static let modelName = "gemini-1.5-flash"
    }
    
    enum Database {
        static let users = "users"
        static let chats = "chats"
        static let messages = "messages"
        static let userChats = "user_chats"
        static let infoConnected = ".info/connected"
        static let chatIdSeparator = "_"
        
        enum User {
            static let uid = "uid"
            static let email = "email"
            static let fullName = "fullName"
            static let profileImageUrl = "profileImageUrl"
            static let learningLanguage = "learningLanguage"
        }
        
        enum Chat {
            static let id = "id"
            static let participants = "participants"
            static let createdAt = "createdAt"
            static let lastMessage = "lastMessage"
        }
        
        enum Message {
            static let id = "id"
            static let text = "text"
            static let senderId = "senderId"
            static let senderName = "senderName"
            static let sentAt = "sentAt"
            static let messageType = "messageType"
            static let imageURL = "imageURL"
            static let isEdited = "isEdited"
            static let replyTo = "replyTo"
        }
        
        enum Presence {
            static let root = "presence"
            static let isOnline = "isOnline"
            static let lastSeen = "lastSeen"
        }
    }
    
    enum Storage {
        static let profileImages = "profile_images"
        static let chatImages = "chat_images"
        static let imageExtension = ".jpg"
    }
    
    enum DefaultValues {
        static let defaultFullName = "Unknown"
        static let defaultEmail = "No email"
        static let defaultImageText = "Imagen"
    }
    
    enum Errors {
        enum Domain {
            static let chatRepository = "ChatRepository"
            static let messageDataSource = "messageDataSource"
            static let chatBotDataSource = "ChatBotDataSourceError"
        }
    }
}
