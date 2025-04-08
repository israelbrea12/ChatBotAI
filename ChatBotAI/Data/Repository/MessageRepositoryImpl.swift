//
//  MessageRepositoryImpl.swift
//  ChatBotAI
//
//  Created by Israel Brea Piñero on 7/4/25.
//

import Foundation
import UIKit

class MessageRepositoryImpl: MessageRepository {
    
    private let messageDataSource: MessageDataSource
    
    init(messageDataSource: MessageDataSource) {
        self.messageDataSource = messageDataSource
    }
    
    func sendMessage(chatId: String, message: Message) async -> Result<Bool, AppError> {
        do{
            try  await messageDataSource.sendMessage(chatId: chatId, message: message)
            return .success(true)
        }catch{
            return .failure(error.toAppError())
        }
    }
}
